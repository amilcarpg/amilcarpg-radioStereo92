# Stereo 92 FM

Aplicación Flutter de streaming de radio para Android y iOS. Incluye audio en
segundo plano, controles del sistema, reconexión automática, temporizador,
accesibilidad, localización ES/EN/PT/FR y telemetría opcional con consentimiento.

## Desarrollo local

Requisitos: Flutter 3.29.2, Dart 3.7, Java 17 o superior y Android SDK 35.

```shell
flutter pub get
flutter analyze
flutter test
flutter run
```

Sin Firebase configurado, la aplicación sigue funcionando con el stream HTTPS
local. En modo debug se mostrará un mensaje indicando que Remote Config,
Analytics y Crashlytics están deshabilitados.

## Configurar Firebase

1. Crear un proyecto en Firebase y registrar Android e iOS con el identificador
   `com.focuzlab.stereo92fm`.
2. Instalar FlutterFire CLI y ejecutar `flutterfire configure` desde esta carpeta.
3. Confirmar que Android contiene `android/app/google-services.json`, iOS contiene
   `ios/Runner/GoogleService-Info.plist` y que los plugins Gradle indicados por
   FlutterFire quedaron aplicados.
4. Crear en Remote Config:
   - `stream_url_primary`: `https://sonic.globalstream.pro:10918/stream`
   - `stream_url_fallback`: vacío hasta disponer de un respaldo.
   - `fallback_enabled`: `false`.
5. Publicar la plantilla y probar consentimiento aceptado y rechazado.

Analytics y Crashlytics están desactivados nativamente por defecto. Solo se
habilitan después del consentimiento guardado por la aplicación.

## Publicación

Android no usa la clave debug para builds release. Crear `android/key.properties`
y una configuración de firma privada en el entorno de publicación; nunca versionar
la clave ni sus contraseñas. Para iOS, seleccionar el equipo y perfiles asociados
al bundle `com.focuzlab.stereo92fm` en Xcode.

Antes de publicar, ejecutar pruebas manuales en dispositivos reales con pantalla
bloqueada, Bluetooth/auriculares, llamada entrante, pérdida de red y temporizador.
