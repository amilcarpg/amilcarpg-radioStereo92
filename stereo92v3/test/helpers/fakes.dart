import 'dart:async';

import 'package:stereo92v3/core/audio/radio_playback_controller.dart';
import 'package:stereo92v3/core/telemetry/telemetry_service.dart';
import 'package:stereo92v3/core/volume/system_volume_controller.dart';

class FakeRadioPlaybackController implements RadioPlaybackController {
  final StreamController<RadioPlaybackStatus> _statuses =
      StreamController<RadioPlaybackStatus>.broadcast();
  final StreamController<Object> _errors = StreamController<Object>.broadcast();

  @override
  RadioPlaybackStatus status = RadioPlaybackStatus.idle;

  @override
  bool wantsToPlay = false;

  @override
  Stream<Object> get errorStream => _errors.stream;

  @override
  Stream<RadioPlaybackStatus> get statusStream => _statuses.stream;

  void emit(RadioPlaybackStatus value) {
    status = value;
    _statuses.add(value);
  }

  void emitError(Object error) => _errors.add(error);

  @override
  Future<void> pause() async {
    wantsToPlay = false;
    emit(RadioPlaybackStatus.paused);
  }

  @override
  Future<void> play() async {
    wantsToPlay = true;
    emit(RadioPlaybackStatus.playing);
  }

  @override
  Future<void> retry() async {
    wantsToPlay = true;
    emit(RadioPlaybackStatus.retrying);
  }

  @override
  Future<void> stop() async {
    wantsToPlay = false;
    emit(RadioPlaybackStatus.idle);
  }

  Future<void> dispose() async {
    await _statuses.close();
    await _errors.close();
  }
}

class FakeTelemetryService implements TelemetryService {
  bool collectionEnabled = false;
  final List<String> events = <String>[];
  final List<Object> errors = <Object>[];

  @override
  bool get enabled => collectionEnabled;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    if (enabled) events.add(name);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) async {
    if (enabled) errors.add(error);
  }

  @override
  Future<void> setEnabled(bool value) async {
    collectionEnabled = value;
  }
}

class MemoryConsentStore implements ConsentStore {
  MemoryConsentStore([this.value]);

  bool? value;

  @override
  Future<bool?> read() async => value;

  @override
  Future<void> write(bool value) async {
    this.value = value;
  }
}

class FakeSystemVolumeController implements SystemVolumeController {
  double value = 0.5;
  void Function(double value)? listener;

  @override
  void addListener(void Function(double value) listener) {
    this.listener = listener;
  }

  @override
  void dispose() {}

  @override
  Future<double> getVolume() async => value;

  @override
  Future<void> setVolume(double value) async {
    this.value = value;
    listener?.call(value);
  }
}
