import 'package:flutter_test/flutter_test.dart';
import 'package:stereo92v3/core/config/stream_config_repository.dart';

class _RemoteProvider implements RemoteStreamConfigProvider {
  _RemoteProvider(this.values);

  final Map<String, Object?> values;

  @override
  Future<Map<String, Object?>> fetch() async => values;
}

void main() {
  test('uses a valid HTTPS primary and distinct enabled fallback', () async {
    final repository = StreamConfigRepository(
      remoteProvider: _RemoteProvider(<String, Object?>{
        'stream_url_primary': 'https://radio.example/live',
        'stream_url_fallback': 'https://backup.example/live',
        'fallback_enabled': true,
      }),
    );

    final config = await repository.refresh();

    expect(config.candidates, hasLength(2));
    expect(config.primaryUrl.host, 'radio.example');
  });

  test('keeps the last valid value when remote data is unsafe', () async {
    final repository = StreamConfigRepository(
      remoteProvider: _RemoteProvider(<String, Object?>{
        'stream_url_primary': 'http://unsafe.example/live',
        'stream_url_fallback': '',
        'fallback_enabled': true,
      }),
    );

    final config = await repository.refresh();

    expect(config.primaryUrl.toString(), defaultStreamUrl);
    expect(config.fallbackEnabled, isFalse);
  });
}
