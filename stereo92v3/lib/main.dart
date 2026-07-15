import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/stereo92_app.dart';
import 'core/audio/stereo_audio_handler.dart';
import 'core/config/stream_config_repository.dart';
import 'core/telemetry/telemetry_service.dart';
import 'core/timer/shutdown_timer_controller.dart';
import 'core/volume/system_volume_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseAvailable = await _initializeFirebase();
  final telemetry = FirebaseTelemetryService(
    firebaseAvailable: firebaseAvailable,
  );
  final consent = TelemetryConsentService(
    store: SharedPreferencesConsentStore(),
    telemetry: telemetry,
  );
  await consent.initialize();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    telemetry.recordError(
      details.exception,
      details.stack ?? StackTrace.current,
      fatal: true,
      reason: 'flutter_framework',
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    telemetry.recordError(
      error,
      stackTrace,
      fatal: true,
      reason: 'unhandled_async',
    );
    return true;
  };

  final streamConfig = StreamConfigRepository(
    remoteProvider: firebaseAvailable
        ? FirebaseRemoteStreamConfigProvider(FirebaseRemoteConfig.instance)
        : null,
  );
  final playback = await AudioService.init(
    builder: () => StereoAudioHandler(
      streamConfig: streamConfig,
      telemetry: telemetry,
    ),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.focuzlab.stereo92fm.playback',
      androidNotificationChannelName: 'Stereo 92 FM',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
    ),
  );
  final timer = ShutdownTimerController(
    playback: playback,
    telemetry: telemetry,
  );

  runApp(
    Stereo92App(
      playback: playback,
      timer: timer,
      consent: consent,
      volume: DeviceSystemVolumeController(),
    ),
  );
}

Future<bool> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } catch (error) {
    if (kDebugMode) {
      debugPrint(
        'Firebase is not configured. Using local stream settings: $error',
      );
    }
    return false;
  }
}
