import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/audio/radio_playback_controller.dart';
import '../core/telemetry/telemetry_service.dart';
import '../core/timer/shutdown_timer_controller.dart';
import '../core/volume/system_volume_controller.dart';
import '../features/player/radio_player_page.dart';
import '../l10n/generated/app_localizations.dart';

class Stereo92App extends StatelessWidget {
  const Stereo92App({
    super.key,
    required this.playback,
    required this.timer,
    required this.consent,
    required this.volume,
    this.locale,
  });

  final RadioPlaybackController playback;
  final ShutdownTimerController timer;
  final TelemetryConsentService consent;
  final SystemVolumeController volume;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Stereo 92',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) return supported;
          }
        }
        return const Locale('es');
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.soraTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: RadioPlayerPage(
        playback: playback,
        timer: timer,
        consent: consent,
        volume: volume,
      ),
    );
  }
}
