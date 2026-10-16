# MiVehiculoAAA

Proyecto académico desarrollado para la asignatura **Computación Móvil** de UNIMINUTO.

MiVehiculoAAA es una aplicación móvil para llevar el control básico de uno o varios vehículos. Permite registrar vehículos, kilometraje, mantenimientos, documentos, gastos, evidencias fotográficas y alertas. También tiene un perfil administrador para gestionar usuarios.

## Integrantes

- Juan Nicolas Acevedo López
- Stiven David Arevalo Osorio
- Jaider Estiven Avendaño Rodríguez

**Tutor:** Edwin Albeiro Ramos Villamil

---

## 1. Objetivo del proyecto

El objetivo de MiVehiculoAAA es centralizar información que normalmente se lleva de forma separada, por ejemplo mantenimientos, kilometraje, documentos y gastos de un vehículo.

La aplicación maneja dos perfiles:

- **Propietario:** administra sus propios vehículos y la información asociada a ellos.
- **Administrador:** administra usuarios del sistema.

Una regla importante del proyecto es que un propietario solo puede consultar y modificar la información de sus propios vehículos.

---

## 2. Tecnologías utilizadas

### Aplicación móvil

- Flutter 3.47.6
- Dart 3.13.5
- Riverpod para manejo de estado
- go_router para navegación
- Dio para consumo de la API REST
- flutter_secure_storage para guardar el token JWT
- image_picker para captura de fotografías
- flutter_launcher_icons para el icono de Android

### Backend

- ASP.NET Core Web API
- .NET 8
- Entity Framework Core
- Npgsql
- JWT Bearer Authentication
- BCrypt para contraseñas
- Swagger para probar y documentar la API

### Base de datos

- PostgreSQL

### Herramientas de desarrollo

- Git y GitHub
- Android Studio
- Android Emulator API 36
- Puro como administrador de Flutter
- Figma para el diseño de las interfaces

---

## 3. Arquitectura general

La solución se separó en tres partes principales:

```text
Usuario
  |
  v
Aplicación Flutter
  |
  | HTTP / REST / JSON
  | Token JWT
  v
ASP.NET Core Web API
  |
  | Servicios + Entity Framework Core
  v
PostgreSQL
```

El teléfono o emulador **no se conecta directamente a PostgreSQL**.

Flutter siempre se comunica con la API. La API valida el usuario, aplica las reglas del sistema y después consulta o modifica PostgreSQL.

### Ejemplo: registrar un vehículo

El flujo simplificado es:

```text
Formulario Registrar vehículo
        |
        v
Provider de vehículos
        |
        v
Repositorio API de vehículos
        |
        v
Dio
        |
        | POST /api/vehiculos
        | Authorization: Bearer <JWT>
        v
VehiculosController
        |
        v
VehiculoService
        |
        v
MiVehiculoDbContext
        |
        v
PostgreSQL
```

La respuesta hace el camino contrario hasta que Flutter actualiza la pantalla.

---

## 4. Estructura del repositorio

```text
MiVehiculoAAA/
|
+-- mobile/              Aplicación Flutter
|
+-- backend/             API ASP.NET Core
|
+-- database/            Scripts SQL complementarios
|
+-- docs/                Documentación del proyecto
|
+-- README.md            Documento general del proyecto
```

---

## 5. Estructura de Flutter

La aplicación móvil está ubicada en:

```text
mobile/
```

La carpeta principal del código es:

```text
mobile/lib/
```

### `lib/main.dart`

Es el punto de entrada de Flutter.

Su responsabilidad principal es iniciar la aplicación dentro de `ProviderScope`, necesario para Riverpod.

### `lib/app/`

Contiene configuración general de la aplicación.

```text
app/
+-- app.dart
+-- router/
+-- theme/
```

#### `app.dart`

Crea `MaterialApp.router` y conecta la aplicación con GoRouter y el tema visual.

#### `router/`

Define las rutas y las pantallas a las que puede navegar la aplicación.

Algunos ejemplos:

```text
/login
/register
/dashboard
/vehicles
/vehicles/register
/vehicles/detail
/maintenance
/maintenance/register
/maintenance/detail
/maintenance/edit
/admin
/admin/users
```

#### `theme/`

Centraliza colores y configuración visual para evitar repetir valores en cada pantalla.

### `lib/core/`

Contiene componentes usados por varias funcionalidades.

Entre los elementos importantes están:

- configuración del cliente HTTP;
- configuración de la URL de la API;
- manejo de errores;
- almacenamiento seguro;
- catálogos compartidos.

### `core/network/api_config.dart`

En el emulador Android la API se consulta mediante:

```text
http://10.0.2.2:5150
```

En Android Emulator, `10.0.2.2` representa el `localhost` del equipo Windows.

Para probar desde un teléfono físico esta dirección debe cambiarse por la IP del equipo que ejecuta la API, por ejemplo:

```text
http://192.168.1.50:5150
```

El teléfono y el computador deben estar en la misma red.

### `core/network/api_client.dart`

Centraliza Dio y las llamadas HTTP.

También permite adjuntar el token JWT a las solicitudes autenticadas.

### `features/`

La aplicación está organizada por funcionalidades para evitar tener todo el código en una sola carpeta.

Las principales son:

```text
features/
+-- auth/
+-- dashboard/
+-- vehicles/
+-- maintenance/
+-- mileage/
+-- documents/
+-- expenses/
+-- notifications/
+-- profile/
+-- admin/
```

En varias funcionalidades se usa esta separación:

```text
feature/
+-- domain/
+-- data/
+-- presentation/
```

#### `domain`

Define entidades e interfaces que representan el negocio.

#### `data`

Contiene las implementaciones que consumen la API.

#### `presentation`

Contiene pantallas y providers de Riverpod.

---

## 6. Autenticación en Flutter

El módulo se encuentra en:

```text
mobile/lib/features/auth/
```

El flujo es:

```text
LoginPage
  -> AuthProvider
  -> ApiAuthRepository
  -> ApiClient / Dio
  -> /api/auth/login
```

Cuando el backend valida las credenciales devuelve un JWT.

El token se guarda usando:

```text
flutter_secure_storage
```

Al volver a abrir la aplicación, la sesión puede restaurarse consultando el perfil del usuario.

Al cerrar o cambiar de sesión se invalidan los providers asociados al usuario para evitar que se muestren datos del propietario anterior.

Este comportamiento se probó específicamente porque durante el desarrollo se detectó que un usuario nuevo podía ver temporalmente vehículos que Riverpod todavía conservaba en memoria. El backend no estaba entregando datos incorrectos; el problema era estado residual del cliente móvil y fue corregido limpiando los providers al cambiar de sesión.

---

## 7. Backend ASP.NET Core

El backend está ubicado en:

```text
backend/
```

La solución principal es:

```text
backend/MiVehiculoAAA.sln
```

La solución está dividida en cuatro proyectos.

```text
MiVehiculoAAA.Domain
MiVehiculoAAA.Application
MiVehiculoAAA.Infrastructure
MiVehiculoAAA.Api
```

### 7.1 Domain

Ruta:

```text
backend/MiVehiculoAAA.Domain/
```

Contiene las entidades principales del sistema.

Ejemplos:

- `Usuario`
- `Rol`
- `Vehiculo`
- `TipoVehiculo`
- `Mantenimiento`
- `TipoMantenimiento`
- `Kilometraje`
- `Documento`
- `TipoDocumento`
- `Gasto`
- `CategoriaGasto`
- `Alerta`

Esta capa representa los datos y conceptos principales del negocio.

### 7.2 Application

Ruta:

```text
backend/MiVehiculoAAA.Application/
```

Contiene contratos, DTO y configuraciones que usa la aplicación.

Por ejemplo, aquí se definen interfaces como:

- servicios de autenticación;
- vehículos;
- kilometraje;
- mantenimientos;
- documentos;
- gastos;
- alertas;
- próximos mantenimientos;
- administración de usuarios.

Infrastructure implementa estas interfaces.

### 7.3 Infrastructure

Ruta:

```text
backend/MiVehiculoAAA.Infrastructure/
```

Es donde se implementa el acceso real a PostgreSQL y gran parte de las reglas de negocio.

Servicios principales:

```text
Auth/AuthService.cs
Vehiculos/VehiculoService.cs
Kilometrajes/KilometrajeService.cs
Mantenimientos/MantenimientoService.cs
Documentos/DocumentoService.cs
Gastos/GastoService.cs
Alertas/AlertaService.cs
ProximosMantenimientos/ProximoMantenimientoService.cs
UsuariosAdmin/UsuarioAdminService.cs
Catalogos/CatalogoService.cs
```

También contiene:

```text
Data/MiVehiculoDbContext.cs
```

`MiVehiculoDbContext` es la clase que conecta Entity Framework Core con PostgreSQL.

### 7.4 API

Ruta:

```text
backend/MiVehiculoAAA.Api/
```

Contiene los controladores HTTP y la configuración de la aplicación web.

El archivo principal es:

```text
Program.cs
```

Entre sus responsabilidades están:

- leer la cadena de conexión;
- configurar PostgreSQL con Npgsql;
- configurar JWT;
- registrar los servicios con inyección de dependencias;
- habilitar autorización;
- habilitar Swagger;
- configurar archivos estáticos para evidencias;
- mapear los controladores.

---

## 8. Controladores y endpoints principales

### Autenticación

```text
POST /api/auth/registro
POST /api/auth/login
GET  /api/auth/perfil
POST /api/auth/logout
```

### Catálogos

```text
GET /api/catalogos/tipos-vehiculo
GET /api/catalogos/tipos-mantenimiento
GET /api/catalogos/tipos-documento
GET /api/catalogos/categorias-gasto
```

### Vehículos

```text
GET    /api/vehiculos
GET    /api/vehiculos/{id}
POST   /api/vehiculos
PUT    /api/vehiculos/{id}
DELETE /api/vehiculos/{id}
```

### Kilometraje

```text
GET  /api/vehiculos/{vehiculoId}/kilometrajes
POST /api/vehiculos/{vehiculoId}/kilometrajes
```

### Mantenimientos

```text
GET    /api/vehiculos/{vehiculoId}/mantenimientos
GET    /api/mantenimientos/{id}
POST   /api/vehiculos/{vehiculoId}/mantenimientos
PUT    /api/mantenimientos/{id}
DELETE /api/mantenimientos/{id}
GET    /api/mantenimientos/proximos
```

### Documentos

```text
GET    /api/vehiculos/{vehiculoId}/documentos
POST   /api/vehiculos/{vehiculoId}/documentos
PUT    /api/documentos/{id}
DELETE /api/documentos/{id}
```

### Gastos

```text
GET    /api/vehiculos/{vehiculoId}/gastos
POST   /api/vehiculos/{vehiculoId}/gastos
PUT    /api/gastos/{id}
DELETE /api/gastos/{id}
```

### Evidencias

```text
POST /api/evidencias
```

Permite cargar imágenes JPG, JPEG, PNG o WEBP.

### Alertas

```text
GET  /api/alertas
POST /api/alertas/generar
PUT  /api/alertas/{id}/leida
```

### Administración de usuarios

Estas rutas requieren el rol `ADMINISTRADOR`.

```text
GET    /api/admin/usuarios
GET    /api/admin/usuarios/{id}
POST   /api/admin/usuarios
PUT    /api/admin/usuarios/{id}
DELETE /api/admin/usuarios/{id}
PUT    /api/admin/usuarios/{id}/activar
```

---

## 9. Base de datos PostgreSQL

La aplicación utiliza PostgreSQL como almacenamiento persistente.

El `DbContext` registra estas entidades:

| Tabla lógica | Función |
|---|---|
| roles | Perfiles del sistema |
| usuarios | Datos de acceso y datos personales |
| tipos_vehiculo | Catálogo de tipos de vehículo |
| vehiculos | Vehículos registrados por los propietarios |
| tipos_mantenimiento | Catálogo de mantenimiento |
| mantenimientos | Historial de mantenimientos |
| kilometrajes | Historial de lecturas |
| tipos_documento | Catálogo de documentos |
| documentos | Documentos de los vehículos |
| categorias_gasto | Catálogo de categorías |
| gastos | Gastos asociados a los vehículos |
| alertas | Alertas del sistema |

### Relaciones más importantes

```text
Rol
 |
 +--< Usuario
        |
        +--< Vehiculo
                |
                +--< Kilometraje
                +--< Mantenimiento
                +--< Documento
                +--< Gasto
                +--< Alerta
```

Un vehículo también referencia su tipo:

```text
TipoVehiculo 1 ---- N Vehiculo
```

Un mantenimiento referencia su tipo:

```text
TipoMantenimiento 1 ---- N Mantenimiento
```

Un documento referencia su tipo:

```text
TipoDocumento 1 ---- N Documento
```

Un gasto referencia su categoría:

```text
CategoriaGasto 1 ---- N Gasto
```

---

## 10. Campos principales de las entidades

### Usuario

Campos principales:

- `Id`
- `RolId`
- `Nombres`
- `Apellidos`
- `Telefono`
- `Correo`
- `PasswordHash`
- `Activo`
- `FechaCreacion`
- `FechaActualizacion`

Las contraseñas no se guardan en texto plano.

### Vehículo

- `Id`
- `UsuarioId`
- `TipoVehiculoId`
- `Marca`
- `Modelo`
- `Anio`
- `Placa`
- `Kilometraje`
- `Activo`
- fechas de auditoría

`UsuarioId` permite identificar a qué propietario pertenece el vehículo.

### Mantenimiento

- vehículo;
- tipo;
- fecha;
- kilometraje;
- costo;
- taller;
- próximo kilometraje;
- próxima fecha;
- observaciones.

### Kilometraje

- vehículo;
- valor;
- fecha;
- observaciones.

### Documento

- vehículo;
- tipo de documento;
- número de referencia;
- entidad emisora;
- fecha de expedición;
- fecha de vencimiento;
- ruta del archivo o evidencia;
- observaciones.

### Gasto

- vehículo;
- categoría;
- descripción;
- valor;
- fecha;
- soporte;
- observaciones.

### Alerta

- usuario;
- vehículo;
- tipo;
- título;
- mensaje;
- fecha de alerta;
- estado de lectura;
- estado activo.

---

## 11. Seguridad

El proyecto aplica varias medidas básicas de seguridad.

### Contraseñas

Las contraseñas se guardan utilizando BCrypt y no se almacenan en texto plano.

### JWT

Después del inicio de sesión el backend genera un JWT.

El móvil lo envía en las solicitudes protegidas:

```text
Authorization: Bearer <token>
```

### Roles

Existen dos perfiles principales:

```text
PROPIETARIO
ADMINISTRADOR
```

El backend usa autorización por roles para las funciones administrativas.

### Aislamiento de información

El propietario solo puede trabajar con vehículos asociados a su usuario autenticado.

Además del filtrado en backend, Flutter limpia el estado asociado a la sesión cuando se cambia de usuario.

---

## 12. Requisitos funcionales implementados

El proyecto contempla 26 requisitos funcionales.

### Gestión de usuarios

- RF-01 Autorregistro
- RF-02 Inicio de sesión
- RF-03 Cierre de sesión
- RF-04 Registrar usuario
- RF-05 Consultar usuarios
- RF-06 Consultar usuario por ID
- RF-07 Actualizar usuario
- RF-08 Desactivar usuario

Como mejora adicional se implementó la reactivación de usuarios inactivos.

### Gestión vehicular

- RF-09 Registrar vehículo
- RF-10 Consultar vehículos del propietario
- RF-11 Consultar vehículo por ID
- RF-12 Actualizar vehículo
- RF-13 Eliminar vehículo
- RF-14 Registrar mantenimiento
- RF-15 Consultar historial de mantenimiento
- RF-16 Actualizar mantenimiento
- RF-17 Eliminar mantenimiento
- RF-18 Registrar kilometraje
- RF-19 Consultar historial de kilometraje
- RF-20 Registrar documentos
- RF-21 Gestionar vencimiento de documentos
- RF-22 Registrar gastos
- RF-23 Consultar gastos
- RF-24 Capturar fotografía
- RF-25 Generar alertas
- RF-26 Consultar próximos mantenimientos

---

## 13. Requisitos no funcionales tenidos en cuenta

Durante el desarrollo se tuvieron en cuenta principalmente:

- interfaz sencilla;
- funcionamiento inicial en Android;
- seguridad de contraseñas;
- control de acceso por perfil;
- protección de datos entre propietarios;
- estructura modular;
- catálogos escalables;
- validación de datos;
- manejo de errores;
- diseño adaptable.

---

## 14. Configuración local del backend

Por seguridad, la cadena de conexión y la llave JWT no deben quedar publicadas en GitHub.

Se manejan mediante configuración local/user-secrets.

El backend espera:

```text
ConnectionStrings:PostgreSQL
Jwt:Key
```

La configuración general de JWT sí se encuentra en `appsettings.json`, por ejemplo el emisor, audiencia y tiempo de expiración.

Para ejecutar la API:

```powershell
cd C:\DESARROLLOS\MiVehiculoAAA\backend\MiVehiculoAAA.Api
dotnet run
```

En desarrollo se utiliza:

```text
http://localhost:5150
```

Swagger puede abrirse en:

```text
http://localhost:5150/swagger
```

---

## 15. Ejecución de Flutter

Primero iniciar el emulador Android.

Después:

```powershell
cd C:\DESARROLLOS\MiVehiculoAAA\mobile

puro flutter pub get
puro flutter run -d emulator-5554 --no-dds
```

Antes de entregar un cambio se utilizan:

```powershell
puro flutter analyze
puro flutter test
```

---

## 16. Compilación del backend

```powershell
cd C:\DESARROLLOS\MiVehiculoAAA\backend

dotnet build .\MiVehiculoAAA.sln
```

El objetivo es terminar con:

```text
0 Errores
```

---

## 17. Generación de APK

Para generar la versión release:

```powershell
cd C:\DESARROLLOS\MiVehiculoAAA\mobile

puro flutter clean
puro flutter pub get
puro flutter build apk --release
```

La APK queda en:

```text
mobile\build\app\outputs\flutter-apk\app-release.apk
```

En la última construcción validada el APK tuvo un tamaño aproximado de **54.13 MB**.

---

## 18. Pruebas realizadas

Durante el desarrollo se ejecutaron pruebas de:

- inicio y cierre de sesión;
- restauración de sesión;
- registro de usuarios;
- administración de usuarios;
- desactivación y reactivación;
- registro, consulta, edición y eliminación de vehículos;
- aislamiento entre propietarios;
- kilometraje;
- mantenimientos;
- edición y eliminación de mantenimiento;
- documentos;
- gastos;
- evidencias mediante cámara;
- alertas;
- próximos mantenimientos;
- navegación;
- compilación del backend;
- análisis estático de Flutter;
- tests automatizados de Flutter.

Comandos utilizados frecuentemente:

```powershell
dotnet build .\MiVehiculoAAA.sln
puro flutter analyze
puro flutter test
```

---

## 19. Demostración sugerida para la sustentación

Para mostrar el funcionamiento completo del sistema se puede seguir este orden:

### 1. Mostrar PostgreSQL

Abrir la base de datos y enseñar las tablas principales:

```text
usuarios
roles
vehiculos
mantenimientos
kilometrajes
documentos
gastos
alertas
```

### 2. Mostrar la API

Ejecutar:

```powershell
dotnet run
```

Explicar que la API queda escuchando en el puerto `5150`.

Abrir Swagger para mostrar los endpoints.

### 3. Mostrar el emulador

Ejecutar Flutter en el AVD API 36.

### 4. Realizar un registro

Crear un propietario desde el formulario de registro.

### 5. Verificar PostgreSQL

Consultar la tabla de usuarios y mostrar que el registro llegó a la base de datos.

### 6. Iniciar sesión

Explicar que Flutter envía correo y contraseña a:

```text
POST /api/auth/login
```

La API valida la contraseña y devuelve un JWT.

### 7. Registrar un vehículo

Crear un vehículo desde Flutter.

Después mostrar en PostgreSQL que el vehículo fue almacenado y quedó asociado al `UsuarioId` del propietario.

### 8. Mostrar módulos asociados

Registrar o consultar:

- kilometraje;
- mantenimiento;
- documento;
- gasto.

### 9. Mostrar administrador

Entrar con un administrador y enseñar la gestión de usuarios.

### 10. Explicar la comunicación

Una forma corta de explicarlo durante la presentación es:

> La interfaz está desarrollada en Flutter. Cuando el usuario realiza una operación, el provider llama a un repositorio y este utiliza Dio para enviar una petición REST a la API ASP.NET Core. La API recibe la petición en un controller, llama al servicio correspondiente y Entity Framework Core utiliza Npgsql para leer o escribir la información en PostgreSQL. La respuesta vuelve como JSON a Flutter y Riverpod actualiza la interfaz.

---

## 20. Flujo que se debe saber explicar

### Registro de usuario

```text
Registro Flutter
-> AuthProvider
-> ApiAuthRepository
-> Dio
-> POST /api/auth/registro
-> AuthController
-> AuthService
-> MiVehiculoDbContext
-> PostgreSQL
```

### Registro de vehículo

```text
VehicleRegisterPage
-> VehiclesProvider
-> ApiVehicleRepository
-> Dio
-> POST /api/vehiculos
-> VehiculosController
-> VehiculoService
-> MiVehiculoDbContext
-> PostgreSQL
```

### Consulta de vehículos

```text
Dashboard / Mis vehículos
-> VehiclesProvider
-> ApiVehicleRepository
-> GET /api/vehiculos
-> VehiculosController
-> VehiculoService
-> PostgreSQL
```

El backend usa la identidad del JWT para devolver únicamente los vehículos que corresponden al propietario autenticado.

---

## 21. Estado actual

Actualmente el proyecto cuenta con:

- frontend Flutter funcional;
- backend ASP.NET Core funcional;
- persistencia PostgreSQL;
- autenticación JWT;
- roles Administrador y Propietario;
- 26 requisitos funcionales cubiertos;
- cámara/evidencias;
- alertas y próximos mantenimientos;
- administración de usuarios;
- logo e icono propios;
- APK release generada;
- repositorio Git con historial de cambios.

---

## 22. Repositorio

Repositorio del proyecto:

```text
https://github.com/David-1399/MiVehiculoAAA.git
```

Rama principal:

```text
master
```

---

## 23. Nota sobre información sensible

No se deben subir al repositorio:

- contraseña de PostgreSQL;
- cadena de conexión con credenciales;
- llave JWT real;
- tokens;
- keystores privados.

Estos valores deben permanecer en configuración local o mecanismos como `dotnet user-secrets`.

---

## 24. Conclusión

MiVehiculoAAA comenzó como una propuesta académica con prototipos y datos de demostración. Durante el desarrollo se fue conectando cada módulo a una API real y a PostgreSQL.

La estructura final separa la interfaz móvil, la lógica del backend y la persistencia. Esto permite entender claramente qué responsabilidad tiene cada parte y facilita continuar agregando funcionalidades sin concentrar toda la lógica en un solo proyecto.

El punto más importante de la arquitectura es que Flutter nunca accede directamente a PostgreSQL. Toda operación pasa por la API, donde se valida el usuario, el rol y las reglas del sistema antes de consultar o modificar información.
