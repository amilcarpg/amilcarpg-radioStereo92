import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:just_audio/just_audio.dart';

import '../config/stream_config_repository.dart';
import '../telemetry/telemetry_service.dart';
import 'radio_playback_controller.dart';
import 'retry_backoff.dart';

class StereoAudioHandler extends BaseAudioHandler
    implements RadioPlaybackController {
  StereoAudioHandler({
    required StreamConfigRepository streamConfig,
    required TelemetryService telemetry,
    AudioPlayer? player,
    Connectivity? connectivity,
  })  : _streamConfig = streamConfig,
        _telemetry = telemetry,
        _player = player ?? AudioPlayer(),
        _connectivity = connectivity ?? Connectivity() {
    mediaItem.add(
      MediaItem(
        id: defaultStreamUrl,
        title: 'Stereo 92 FM',
        album: 'Más radio',
        playable: true,
      ),
    );
    _subscriptions.add(
      _player.playerStateStream.listen(_onPlayerStateChanged),
    );
    _subscriptions.add(
      _player.playbackEventStream.listen(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          _handlePlaybackError(error, stackTrace);
        },
      ),
    );
    _subscriptions.add(
      _connectivity.onConnectivityChanged.listen(_onConnectivityChanged),
    );
    unawaited(_configureAudioSession());
    _emitStatus(RadioPlaybackStatus.idle);
    _broadcastPlaybackState();
  }

  final StreamConfigRepository _streamConfig;
  final TelemetryService _telemetry;
  final AudioPlayer _player;
  final Connectivity _connectivity;
  final StreamController<RadioPlaybackStatus> _statusController =
      StreamController<RadioPlaybackStatus>.broadcast();
  final StreamController<Object> _errorController =
      StreamController<Object>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  RadioPlaybackStatus _status = RadioPlaybackStatus.idle;
  bool _wantsToPlay = false;
  bool _loaded = false;
  bool _loading = false;
  bool _interruptedWhilePlaying = false;
  final RetryBackoff _retryBackoff = RetryBackoff();
  int _candidateIndex = 0;
  Timer? _retryTimer;

  @override
  RadioPlaybackStatus get status => _status;

  @override
  bool get wantsToPlay => _wantsToPlay;

  @override
  Stream<RadioPlaybackStatus> get statusStream => _statusController.stream;

  @override
  Stream<Object> get errorStream => _errorController.stream;

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _subscriptions.add(
      session.becomingNoisyEventStream.listen((_) => pause()),
    );
    _subscriptions.add(
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          if (event.type == AudioInterruptionType.duck) {
            unawaited(_player.setVolume(0.35));
          } else {
            _interruptedWhilePlaying = _wantsToPlay && _player.playing;
            unawaited(_player.pause());
          }
        } else {
          unawaited(_player.setVolume(1));
          if (_interruptedWhilePlaying && _wantsToPlay) {
            _interruptedWhilePlaying = false;
            unawaited(_resumeLoadedPlayer());
          }
        }
      }),
    );
  }

  @override
  Future<void> play() async {
    _wantsToPlay = true;
    _retryTimer?.cancel();
    await _telemetry.logEvent('play_requested');
    if (_loaded) {
      await _resumeLoadedPlayer();
      return;
    }
    await _loadAndPlay(refreshConfig: true);
  }

  Future<void> _resumeLoadedPlayer() async {
    if (!_loaded) {
      await _loadAndPlay();
      return;
    }
    unawaited(_player.play());
  }

  Future<void> _loadAndPlay({bool refreshConfig = false}) async {
    if (_loading || !_wantsToPlay) return;
    _loading = true;
    _emitStatus(
      _retryBackoff.attempt == 0
          ? RadioPlaybackStatus.connecting
          : RadioPlaybackStatus.retrying,
    );
    try {
      final config = refreshConfig
          ? await _streamConfig.refresh()
          : _streamConfig.current;
      final candidates = config.candidates;
      if (_candidateIndex >= candidates.length) _candidateIndex = 0;
      await _player.setUrl(candidates[_candidateIndex].toString());
      _loaded = true;
      if (_wantsToPlay) unawaited(_player.play());
    } catch (error, stackTrace) {
      _handlePlaybackError(error, stackTrace);
    } finally {
      _loading = false;
    }
  }

  @override
  Future<void> pause() async {
    _wantsToPlay = false;
    _retryTimer?.cancel();
    await _player.pause();
    _emitStatus(RadioPlaybackStatus.paused);
    await _telemetry.logEvent('playback_paused');
  }

  @override
  Future<void> stop() async {
    _wantsToPlay = false;
    _retryTimer?.cancel();
    await _player.stop();
    _loaded = false;
    _retryBackoff.reset();
    _candidateIndex = 0;
    _emitStatus(RadioPlaybackStatus.idle);
    await super.stop();
  }

  @override
  Future<void> retry() async {
    if (!_wantsToPlay) _wantsToPlay = true;
    _retryTimer?.cancel();
    _loaded = false;
    await _loadAndPlay(refreshConfig: true);
  }

  void _onPlayerStateChanged(PlayerState state) {
    if (state.playing) {
      final wasPlaying = _status == RadioPlaybackStatus.playing;
      _retryBackoff.reset();
      _emitStatus(RadioPlaybackStatus.playing);
      if (!wasPlaying) unawaited(_telemetry.logEvent('playback_started'));
    } else if (state.processingState == ProcessingState.loading ||
        state.processingState == ProcessingState.buffering) {
      if (_wantsToPlay) _emitStatus(RadioPlaybackStatus.connecting);
    } else if (_loaded && !_wantsToPlay) {
      _emitStatus(RadioPlaybackStatus.paused);
    }
    _broadcastPlaybackState();
  }

  void _handlePlaybackError(Object error, StackTrace stackTrace) {
    _loaded = false;
    _errorController.add(error);
    unawaited(
      _telemetry.recordError(
        error,
        stackTrace,
        reason: 'radio_playback',
      ),
    );
    unawaited(_telemetry.logEvent('playback_error'));
    if (_wantsToPlay) {
      _scheduleRetry();
    } else {
      _emitStatus(RadioPlaybackStatus.failed);
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final config = _streamConfig.current;
    if (config.candidates.length > 1) {
      _candidateIndex = (_candidateIndex + 1) % config.candidates.length;
    }
    final delay = _retryBackoff.nextDelay();
    _emitStatus(RadioPlaybackStatus.retrying);
    unawaited(_telemetry.logEvent('retry_started', <String, Object>{
      'attempt': _retryBackoff.attempt,
      'delay_seconds': delay.inSeconds,
    }));
    _retryTimer = Timer(delay, _loadAndPlay);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasNetwork = results.any((result) => result != ConnectivityResult.none);
    if (hasNetwork &&
        _wantsToPlay &&
        (_status == RadioPlaybackStatus.retrying ||
            _status == RadioPlaybackStatus.failed)) {
      _retryTimer?.cancel();
      unawaited(retry());
    }
  }

  void _emitStatus(RadioPlaybackStatus value) {
    if (_status == value) return;
    _status = value;
    _statusController.add(value);
    _broadcastPlaybackState();
  }

  void _broadcastPlaybackState() {
    playbackState.add(
      PlaybackState(
        controls: <MediaControl>[
          if (_wantsToPlay) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const <int>[0],
        processingState: _mapProcessingState(_player.processingState),
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: 0,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    return switch (state) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
  }

  Future<void> disposeResources() async {
    _retryTimer?.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _player.dispose();
    await _statusController.close();
    await _errorController.close();
  }
}
