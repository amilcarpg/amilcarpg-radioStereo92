import 'package:flutter_test/flutter_test.dart';
import 'package:stereo92v3/core/timer/shutdown_timer_controller.dart';

import 'helpers/fakes.dart';

void main() {
  test('timer can be replaced and cancelled cleanly', () async {
    final playback = FakeRadioPlaybackController();
    final telemetry = FakeTelemetryService()..collectionEnabled = true;
    final timer = ShutdownTimerController(
      playback: playback,
      telemetry: telemetry,
    );

    timer.start(const Duration(minutes: 5));
    timer.start(const Duration(minutes: 10));

    expect(timer.isActive, isTrue);
    expect(timer.remaining.inMinutes, 10);

    timer.cancel();

    expect(timer.isActive, isFalse);
    expect(timer.remaining, Duration.zero);
    expect(telemetry.events, containsAll(<String>['timer_set', 'timer_cancelled']));

    timer.dispose();
    await playback.dispose();
  });
}
