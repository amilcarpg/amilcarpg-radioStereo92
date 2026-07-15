import 'package:flutter_test/flutter_test.dart';
import 'package:stereo92v3/core/telemetry/telemetry_service.dart';

import 'helpers/fakes.dart';

void main() {
  test('telemetry stays disabled until explicit consent', () async {
    final telemetry = FakeTelemetryService();
    final store = MemoryConsentStore();
    final consent = TelemetryConsentService(
      store: store,
      telemetry: telemetry,
    );

    await consent.initialize();
    await telemetry.logEvent('play_requested');

    expect(consent.consent, isNull);
    expect(telemetry.events, isEmpty);

    await consent.update(true);
    await telemetry.logEvent('play_requested');

    expect(store.value, isTrue);
    expect(telemetry.events, <String>['play_requested']);
  });
}
