import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class TelemetryService {
  bool get enabled;
  Future<void> setEnabled(bool value);
  Future<void> logEvent(String name, [Map<String, Object>? parameters]);
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  });
}

class FirebaseTelemetryService implements TelemetryService {
  FirebaseTelemetryService({required this.firebaseAvailable});

  final bool firebaseAvailable;
  bool _enabled = false;

  @override
  bool get enabled => firebaseAvailable && _enabled;

  @override
  Future<void> setEnabled(bool value) async {
    _enabled = firebaseAvailable && value;
    if (!firebaseAvailable) return;
    await Future.wait(<Future<void>>[
      FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(_enabled),
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(_enabled),
    ]);
  }

  @override
  Future<void> logEvent(
    String name, [
    Map<String, Object>? parameters,
  ]) async {
    if (!enabled) return;
    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) async {
    if (!enabled) return;
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      fatal: fatal,
      reason: reason,
    );
  }
}

class NoopTelemetryService implements TelemetryService {
  @override
  bool get enabled => false;

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) async {}

  @override
  Future<void> setEnabled(bool value) async {}
}

abstract interface class ConsentStore {
  Future<bool?> read();
  Future<void> write(bool value);
}

class SharedPreferencesConsentStore implements ConsentStore {
  SharedPreferencesConsentStore([SharedPreferencesAsync? preferences])
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _key = 'telemetry_consent_v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<bool?> read() => _preferences.getBool(_key);

  @override
  Future<void> write(bool value) => _preferences.setBool(_key, value);
}

class TelemetryConsentService extends ChangeNotifier {
  TelemetryConsentService({
    required ConsentStore store,
    required TelemetryService telemetry,
  })  : _store = store,
        _telemetry = telemetry;

  final ConsentStore _store;
  final TelemetryService _telemetry;
  bool? _consent;

  bool? get consent => _consent;
  bool get enabled => _consent == true && _telemetry.enabled;

  Future<void> initialize() async {
    _consent = await _store.read();
    await _telemetry.setEnabled(_consent == true);
    notifyListeners();
  }

  Future<void> update(bool value) async {
    await _store.write(value);
    _consent = value;
    await _telemetry.setEnabled(value);
    notifyListeners();
  }
}
