// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Radio Stereo 92';

  @override
  String get stationName => 'Stereo 92 FM';

  @override
  String get stationTagline => 'Más radio';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausar';

  @override
  String get retry => 'Reintentar';

  @override
  String get volume => 'Volumen';

  @override
  String get statusIdle => 'Lista para reproducir';

  @override
  String get statusConnecting => 'Conectando…';

  @override
  String get statusPlaying => 'En vivo';

  @override
  String get statusPaused => 'Reproducción pausada';

  @override
  String get statusRetrying => 'Reconectando…';

  @override
  String get statusFailed => 'No se pudo conectar';

  @override
  String get playbackError => 'No se pudo reproducir la radio. Revisaremos la conexión automáticamente.';

  @override
  String get timerConfigure => 'Configurar temporizador de apagado';

  @override
  String get timerTitle => 'Temporizador de apagado';

  @override
  String timerActive(String time) {
    return 'Apagado en $time';
  }

  @override
  String get timerFinished => 'La reproducción se detuvo al finalizar el temporizador.';

  @override
  String get timerCancel => 'Cancelar temporizador';

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get accept => 'Aceptar';

  @override
  String get close => 'Cerrar';

  @override
  String get privacy => 'Privacidad';

  @override
  String get privacyTitle => 'Ayúdanos a mejorar';

  @override
  String get privacyMessage => 'Con tu permiso, recopilamos datos anónimos de estabilidad y uso para detectar fallos. La radio funciona igual si no aceptas.';

  @override
  String get privacyAccept => 'Aceptar';

  @override
  String get privacyDecline => 'Ahora no';

  @override
  String get telemetrySetting => 'Compartir datos anónimos de uso y errores';

  @override
  String get telemetryOn => 'Activado';

  @override
  String get telemetryOff => 'Desactivado';

  @override
  String get settings => 'Ajustes';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }
}
