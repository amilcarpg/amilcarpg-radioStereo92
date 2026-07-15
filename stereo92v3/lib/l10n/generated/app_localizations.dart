import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Radio Stereo 92'**
  String get appTitle;

  /// No description provided for @stationName.
  ///
  /// In es, this message translates to:
  /// **'Stereo 92 FM'**
  String get stationName;

  /// No description provided for @stationTagline.
  ///
  /// In es, this message translates to:
  /// **'Más radio'**
  String get stationTagline;

  /// No description provided for @play.
  ///
  /// In es, this message translates to:
  /// **'Reproducir'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get pause;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @volume.
  ///
  /// In es, this message translates to:
  /// **'Volumen'**
  String get volume;

  /// No description provided for @statusIdle.
  ///
  /// In es, this message translates to:
  /// **'Lista para reproducir'**
  String get statusIdle;

  /// No description provided for @statusConnecting.
  ///
  /// In es, this message translates to:
  /// **'Conectando…'**
  String get statusConnecting;

  /// No description provided for @statusPlaying.
  ///
  /// In es, this message translates to:
  /// **'En vivo'**
  String get statusPlaying;

  /// No description provided for @statusPaused.
  ///
  /// In es, this message translates to:
  /// **'Reproducción pausada'**
  String get statusPaused;

  /// No description provided for @statusRetrying.
  ///
  /// In es, this message translates to:
  /// **'Reconectando…'**
  String get statusRetrying;

  /// No description provided for @statusFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar'**
  String get statusFailed;

  /// No description provided for @playbackError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reproducir la radio. Revisaremos la conexión automáticamente.'**
  String get playbackError;

  /// No description provided for @timerConfigure.
  ///
  /// In es, this message translates to:
  /// **'Configurar temporizador de apagado'**
  String get timerConfigure;

  /// No description provided for @timerTitle.
  ///
  /// In es, this message translates to:
  /// **'Temporizador de apagado'**
  String get timerTitle;

  /// No description provided for @timerActive.
  ///
  /// In es, this message translates to:
  /// **'Apagado en {time}'**
  String timerActive(String time);

  /// No description provided for @timerFinished.
  ///
  /// In es, this message translates to:
  /// **'La reproducción se detuvo al finalizar el temporizador.'**
  String get timerFinished;

  /// No description provided for @timerCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar temporizador'**
  String get timerCancel;

  /// No description provided for @minutes.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 minuto} other{{count} minutos}}'**
  String minutes(int count);

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @privacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get privacy;

  /// No description provided for @privacyTitle.
  ///
  /// In es, this message translates to:
  /// **'Ayúdanos a mejorar'**
  String get privacyTitle;

  /// No description provided for @privacyMessage.
  ///
  /// In es, this message translates to:
  /// **'Con tu permiso, recopilamos datos anónimos de estabilidad y uso para detectar fallos. La radio funciona igual si no aceptas.'**
  String get privacyMessage;

  /// No description provided for @privacyAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get privacyAccept;

  /// No description provided for @privacyDecline.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get privacyDecline;

  /// No description provided for @telemetrySetting.
  ///
  /// In es, this message translates to:
  /// **'Compartir datos anónimos de uso y errores'**
  String get telemetrySetting;

  /// No description provided for @telemetryOn.
  ///
  /// In es, this message translates to:
  /// **'Activado'**
  String get telemetryOn;

  /// No description provided for @telemetryOff.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get telemetryOff;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @percentValue.
  ///
  /// In es, this message translates to:
  /// **'{percent}%'**
  String percentValue(int percent);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
