import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stereo92v3/app/stereo92_app.dart';
import 'package:stereo92v3/core/telemetry/telemetry_service.dart';
import 'package:stereo92v3/core/timer/shutdown_timer_controller.dart';

import 'helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders localized controls and toggles playback', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.binding.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.binding.platformDispatcher.clearLocaleTestValue();
    });

    final playback = FakeRadioPlaybackController();
    final telemetry = FakeTelemetryService();
    final consent = TelemetryConsentService(
      store: MemoryConsentStore(false),
      telemetry: telemetry,
    );
    await consent.initialize();
    final timer = ShutdownTimerController(
      playback: playback,
      telemetry: telemetry,
    );

    await tester.pumpWidget(
      Stereo92App(
        playback: playback,
        timer: timer,
        consent: consent,
        volume: FakeSystemVolumeController(),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ready to play'), findsOneWidget);
    expect(find.text('Set sleep timer'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();

    expect(playback.wantsToPlay, isTrue);
    expect(find.text('Live'), findsOneWidget);

    timer.dispose();
    await playback.dispose();
  });

  testWidgets('exposes accessible labels with enlarged text', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    tester.binding.platformDispatcher.localeTestValue = const Locale('es');
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      tester.binding.platformDispatcher.clearLocaleTestValue();
    });
    final semantics = tester.ensureSemantics();
    final playback = FakeRadioPlaybackController();
    final telemetry = FakeTelemetryService();
    final consent = TelemetryConsentService(
      store: MemoryConsentStore(false),
      telemetry: telemetry,
    );
    await consent.initialize();
    final timer = ShutdownTimerController(
      playback: playback,
      telemetry: telemetry,
    );

    await tester.pumpWidget(
      Stereo92App(
        playback: playback,
        timer: timer,
        consent: consent,
        volume: FakeSystemVolumeController(),
        locale: const Locale('es'),
      ),
    );
    await tester.pumpAndSettle();

    final playSemantics = tester.getSemantics(
      find.byKey(const ValueKey<String>('play_button')),
    );
    expect(playSemantics.label, contains('Reproducir'));
    expect(tester.takeException(), isNull);

    semantics.dispose();
    timer.dispose();
    await playback.dispose();
  });
}
