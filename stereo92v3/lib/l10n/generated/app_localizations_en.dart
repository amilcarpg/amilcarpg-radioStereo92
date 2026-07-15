// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stereo 92 Radio';

  @override
  String get stationName => 'Stereo 92 FM';

  @override
  String get stationTagline => 'More radio';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get retry => 'Retry';

  @override
  String get volume => 'Volume';

  @override
  String get statusIdle => 'Ready to play';

  @override
  String get statusConnecting => 'Connecting…';

  @override
  String get statusPlaying => 'Live';

  @override
  String get statusPaused => 'Playback paused';

  @override
  String get statusRetrying => 'Reconnecting…';

  @override
  String get statusFailed => 'Unable to connect';

  @override
  String get playbackError => 'The radio could not be played. We will automatically check the connection.';

  @override
  String get timerConfigure => 'Set sleep timer';

  @override
  String get timerTitle => 'Sleep timer';

  @override
  String timerActive(String time) {
    return 'Stopping in $time';
  }

  @override
  String get timerFinished => 'Playback stopped when the timer ended.';

  @override
  String get timerCancel => 'Cancel timer';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get accept => 'Accept';

  @override
  String get close => 'Close';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyTitle => 'Help us improve';

  @override
  String get privacyMessage => 'With your permission, we collect anonymous stability and usage data to detect problems. The radio works the same if you decline.';

  @override
  String get privacyAccept => 'Accept';

  @override
  String get privacyDecline => 'Not now';

  @override
  String get telemetrySetting => 'Share anonymous usage and error data';

  @override
  String get telemetryOn => 'Enabled';

  @override
  String get telemetryOff => 'Disabled';

  @override
  String get settings => 'Settings';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }
}
