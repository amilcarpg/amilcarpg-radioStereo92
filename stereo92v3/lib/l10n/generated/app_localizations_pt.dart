// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Rádio Stereo 92';

  @override
  String get stationName => 'Stereo 92 FM';

  @override
  String get stationTagline => 'Mais rádio';

  @override
  String get play => 'Reproduzir';

  @override
  String get pause => 'Pausar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get volume => 'Volume';

  @override
  String get statusIdle => 'Pronta para reproduzir';

  @override
  String get statusConnecting => 'Conectando…';

  @override
  String get statusPlaying => 'Ao vivo';

  @override
  String get statusPaused => 'Reprodução pausada';

  @override
  String get statusRetrying => 'Reconectando…';

  @override
  String get statusFailed => 'Não foi possível conectar';

  @override
  String get playbackError => 'Não foi possível reproduzir a rádio. Verificaremos a conexão automaticamente.';

  @override
  String get timerConfigure => 'Configurar temporizador';

  @override
  String get timerTitle => 'Temporizador';

  @override
  String timerActive(String time) {
    return 'Desligando em $time';
  }

  @override
  String get timerFinished => 'A reprodução parou ao terminar o temporizador.';

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
  String get accept => 'Aceitar';

  @override
  String get close => 'Fechar';

  @override
  String get privacy => 'Privacidade';

  @override
  String get privacyTitle => 'Ajude-nos a melhorar';

  @override
  String get privacyMessage => 'Com sua permissão, coletamos dados anônimos de estabilidade e uso para detectar falhas. A rádio funciona da mesma forma se você recusar.';

  @override
  String get privacyAccept => 'Aceitar';

  @override
  String get privacyDecline => 'Agora não';

  @override
  String get telemetrySetting => 'Compartilhar dados anônimos de uso e erros';

  @override
  String get telemetryOn => 'Ativado';

  @override
  String get telemetryOff => 'Desativado';

  @override
  String get settings => 'Configurações';

  @override
  String percentValue(int percent) {
    return '$percent%';
  }
}
