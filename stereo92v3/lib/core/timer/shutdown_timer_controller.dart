import 'dart:async';

import 'package:flutter/foundation.dart';

import '../audio/radio_playback_controller.dart';
import '../telemetry/telemetry_service.dart';

class ShutdownTimerController extends ChangeNotifier {
  ShutdownTimerController({
    required RadioPlaybackController playback,
    required TelemetryService telemetry,
  })  : _playback = playback,
        _telemetry = telemetry;

  final RadioPlaybackController _playback;
  final TelemetryService _telemetry;
  Timer? _ticker;
  DateTime? _deadline;
  Duration _remaining = Duration.zero;

  bool get isActive => _deadline != null;
  Duration get remaining => _remaining;

  void start(Duration duration) {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'Must be positive');
    }
    _ticker?.cancel();
    _deadline = DateTime.now().add(duration);
    _remaining = duration;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    unawaited(_telemetry.logEvent('timer_set', <String, Object>{
      'minutes': duration.inMinutes,
    }));
    notifyListeners();
  }

  void cancel() {
    if (!isActive) return;
    _clear();
    unawaited(_telemetry.logEvent('timer_cancelled'));
    notifyListeners();
  }

  void _tick() {
    final deadline = _deadline;
    if (deadline == null) return;
    final remaining = deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _clear();
      unawaited(_playback.pause());
    } else {
      _remaining = remaining;
    }
    notifyListeners();
  }

  void _clear() {
    _ticker?.cancel();
    _ticker = null;
    _deadline = null;
    _remaining = Duration.zero;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
