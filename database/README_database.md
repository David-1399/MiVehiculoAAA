# Base de datos - MiVehiculoAAA

La aplicación utiliza PostgreSQL.

## Orden para crear una instalación nueva

1. Conectarse a PostgreSQL en la base postgres.
2. Ejecutar 000_crear_base_datos.sql.
3. Cambiar la conexión a la base MiVehiculoAAA.
4. Ejecutar 001_schema_inicial.sql.
5. Configurar appsettings.Development.json.
6. Levantar la API.
7. Registrar un usuario desde la aplicación.
8. Opcionalmente ejecutar 003_promover_usuario_admin.sql para convertir un usuario en administrador.

## Configuración local de la API

Copiar:

`backend/MiVehiculoAAA.Api/appsettings.Development.example.json`

como:

`backend/MiVehiculoAAA.Api/appsettings.Development.json`

y configurar localmente la conexión a PostgreSQL y la llave JWT.

Ejemplo de conexión:

`Host=localhost;Port=5432;Database=MiVehiculoAAA;Username=postgres;Password=TU_PASSWORD`

El archivo `appsettings.Development.json` no debe subirse a Git.

## Datos iniciales

`001_schema_inicial.sql` crea los catálogos mínimos requeridos por la API:

- roles `PROPIETARIO` y `ADMINISTRADOR`;
- tipos de vehículo;
- tipos de mantenimiento;
- tipos de documento;
- categorías de gasto.

El rol `PROPIETARIO` es obligatorio para que el autorregistro funcione.
