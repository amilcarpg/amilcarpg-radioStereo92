import 'package:firebase_remote_config/firebase_remote_config.dart';

const String defaultStreamUrl =
    'https://sonic.globalstream.pro:10918/stream';

class StreamConfig {
  const StreamConfig({
    required this.primaryUrl,
    this.fallbackUrl,
    this.fallbackEnabled = false,
  });

  final Uri primaryUrl;
  final Uri? fallbackUrl;
  final bool fallbackEnabled;

  List<Uri> get candidates => <Uri>[
        primaryUrl,
        if (fallbackEnabled && fallbackUrl != null) fallbackUrl!,
      ];
}

abstract interface class RemoteStreamConfigProvider {
  Future<Map<String, Object?>> fetch();
}

class FirebaseRemoteStreamConfigProvider
    implements RemoteStreamConfigProvider {
  FirebaseRemoteStreamConfigProvider(this._remoteConfig);

  final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<Map<String, Object?>> fetch() async {
    await _remoteConfig.setDefaults(const <String, Object>{
      'stream_url_primary': defaultStreamUrl,
      'stream_url_fallback': '',
      'fallback_enabled': false,
    });
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 8),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.fetchAndActivate();
    return <String, Object?>{
      'stream_url_primary': _remoteConfig.getString('stream_url_primary'),
      'stream_url_fallback': _remoteConfig.getString('stream_url_fallback'),
      'fallback_enabled': _remoteConfig.getBool('fallback_enabled'),
    };
  }
}

class StreamConfigRepository {
  StreamConfigRepository({RemoteStreamConfigProvider? remoteProvider})
      : _remoteProvider = remoteProvider,
        _lastValid = StreamConfig(primaryUrl: Uri.parse(defaultStreamUrl));

  final RemoteStreamConfigProvider? _remoteProvider;
  StreamConfig _lastValid;

  StreamConfig get current => _lastValid;

  Future<StreamConfig> refresh() async {
    final provider = _remoteProvider;
    if (provider == null) return _lastValid;

    try {
      final values = await provider.fetch();
      final primary = _parseHttps(values['stream_url_primary']);
      if (primary == null) return _lastValid;

      final fallback = _parseHttps(values['stream_url_fallback']);
      final enabled = values['fallback_enabled'] == true &&
          fallback != null &&
          fallback != primary;
      _lastValid = StreamConfig(
        primaryUrl: primary,
        fallbackUrl: fallback,
        fallbackEnabled: enabled,
      );
    } catch (_) {
      // Remote configuration must never prevent radio playback.
    }
    return _lastValid;
  }

  static Uri? _parseHttps(Object? value) {
    final raw = value?.toString().trim() ?? '';
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return uri;
  }
}
