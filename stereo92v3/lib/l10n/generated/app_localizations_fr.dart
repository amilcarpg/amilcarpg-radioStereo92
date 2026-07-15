// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Radio Stereo 92';

  @override
  String get stationName => 'Stereo 92 FM';

  @override
  String get stationTagline => 'Plus de radio';

  @override
  String get play => 'Écouter';

  @override
  String get pause => 'Pause';

  @override
  String get retry => 'Réessayer';

  @override
  String get volume => 'Volume';

  @override
  String get statusIdle => 'Prête à jouer';

  @override
  String get statusConnecting => 'Connexion…';

  @override
  String get statusPlaying => 'En direct';

  @override
  String get statusPaused => 'Lecture en pause';

  @override
  String get statusRetrying => 'Reconnexion…';

  @override
  String get statusFailed => 'Connexion impossible';

  @override
  String get playbackError => 'La radio n’a pas pu être lue. Nous vérifierons automatiquement la connexion.';

  @override
  String get timerConfigure => 'Régler la minuterie d’arrêt';

  @override
  String get timerTitle => 'Minuterie d’arrêt';

  @override
  String timerActive(String time) {
    return 'Arrêt dans $time';
  }

  @override
  String get timerFinished => 'La lecture s’est arrêtée à la fin de la minuterie.';

  @override
  String get timerCancel => 'Annuler la minuterie';

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
  String get cancel => 'Annuler';

  @override
  String get accept => 'Accepter';

  @override
  String get close => 'Fermer';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get privacyTitle => 'Aidez-nous à améliorer';

  @override
  String get privacyMessage => 'Avec votre autorisation, nous recueillons des données anonymes de stabilité et d’utilisation afin de détecter les problèmes. La radio fonctionne de la même manière si vous refusez.';

  @override
  String get privacyAccept => 'Accepter';

  @override
  String get privacyDecline => 'Pas maintenant';

  @override
  String get telemetrySetting => 'Partager des données anonymes d’utilisation et d’erreurs';

  @override
  String get telemetryOn => 'Activé';

  @override
  String get telemetryOff => 'Désactivé';

  @override
  String get settings => 'Réglages';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }
}
