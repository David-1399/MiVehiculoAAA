# MiVehiculoAAA - Aplicación móvil

Cliente móvil del proyecto MiVehiculoAAA desarrollado con Flutter y Dart.

## Responsabilidad

La aplicación permite a propietarios gestionar vehículos, kilometraje, mantenimientos,
documentos, gastos, evidencias y alertas. El perfil administrador gestiona usuarios.

## Arquitectura móvil

La aplicación está organizada por funcionalidades bajo `lib/features`, con separación
entre `domain`, `data` y `presentation`.

Componentes principales:

- Riverpod: gestión de estado e inyección de dependencias.
- go_router: navegación.
- Dio: consumo de la API REST.
- flutter_secure_storage: almacenamiento seguro del token JWT.
- image_picker: captura de evidencias con la cámara.

## Comunicación

En desarrollo con emulador Android, la aplicación consume la API mediante:

`http://10.0.2.2:5150`

`10.0.2.2` representa el equipo anfitrión desde el emulador Android.

## Ejecución

```powershell
puro flutter pub get
puro flutter analyze
puro flutter test
puro flutter run -d emulator-5554 --no-dds
```

## APK release

```powershell
puro flutter build apk --release
```

Salida esperada:

`build\app\outputs\flutter-apk\app-release.apk`