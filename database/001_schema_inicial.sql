-- ============================================================
-- MiVehiculoAAA
-- 001_schema_inicial.sql
--
-- Ejecutar conectado a la base "MiVehiculoAAA".
-- Crea la estructura principal y los catalogos requeridos
-- por la API.
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- TABLAS DE CATALOGO
-- ============================================================

CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_roles_nombre
    ON roles(nombre);

CREATE TABLE IF NOT EXISTS tipos_vehiculo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_tipos_vehiculo_nombre
    ON tipos_vehiculo(nombre);

CREATE TABLE IF NOT EXISTS tipos_mantenimiento (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(80) NOT NULL,
    categoria VARCHAR(20) NOT NULL,
    descripcion VARCHAR(200),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_tipos_mantenimiento_nombre
    ON tipos_mantenimiento(nombre);

CREATE TABLE IF NOT EXISTS tipos_documento (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(150),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_tipos_documento_nombre
    ON tipos_documento(nombre);

CREATE TABLE IF NOT EXISTS categorias_gasto (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(150),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_categorias_gasto_nombre
    ON categorias_gasto(nombre);

-- ============================================================
-- USUARIOS
-- ============================================================

CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rol_id UUID NOT NULL,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(120) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_usuarios_roles
        FOREIGN KEY (rol_id)
        REFERENCES roles(id)
        ON DELETE RESTRICT
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_usuarios_correo
    ON usuarios(correo);

CREATE INDEX IF NOT EXISTS ix_usuarios_rol_id
    ON usuarios(rol_id);

-- ============================================================
-- VEHICULOS
-- ============================================================

CREATE TABLE IF NOT EXISTS vehiculos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL,
    tipo_vehiculo_id UUID NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    anio INTEGER NOT NULL,
    placa VARCHAR(15) NOT NULL,
    kilometraje INTEGER NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_vehiculos_usuarios
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_vehiculos_tipos_vehiculo
        FOREIGN KEY (tipo_vehiculo_id)
        REFERENCES tipos_vehiculo(id)
        ON DELETE RESTRICT
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_vehiculos_placa
    ON vehiculos(placa);

CREATE INDEX IF NOT EXISTS ix_vehiculos_usuario_id
    ON vehiculos(usuario_id);

CREATE INDEX IF NOT EXISTS ix_vehiculos_tipo_vehiculo_id
    ON vehiculos(tipo_vehiculo_id);

-- ============================================================
-- KILOMETRAJES
-- ============================================================

CREATE TABLE IF NOT EXISTS kilometrajes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL,
    kilometraje INTEGER NOT NULL,
    fecha DATE NOT NULL,
    observaciones TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_kilometrajes_vehiculos
        FOREIGN KEY (vehiculo_id)
        REFERENCES vehiculos(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS ix_kilometrajes_vehiculo_id
    ON kilometrajes(vehiculo_id);

CREATE INDEX IF NOT EXISTS ix_kilometrajes_vehiculo_fecha
    ON kilometrajes(vehiculo_id, fecha);

-- ============================================================
-- MANTENIMIENTOS
-- ============================================================

CREATE TABLE IF NOT EXISTS mantenimientos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL,
    tipo_mantenimiento_id UUID NOT NULL,
    descripcion VARCHAR(250),
    fecha DATE NOT NULL,
    kilometraje INTEGER,
    costo NUMERIC(12,2),
    taller VARCHAR(120),
    proximo_kilometraje INTEGER,
    proxima_fecha DATE,
    observaciones TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_mantenimientos_vehiculos
        FOREIGN KEY (vehiculo_id)
        REFERENCES vehiculos(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_mantenimientos_tipos
        FOREIGN KEY (tipo_mantenimiento_id)
        REFERENCES tipos_mantenimiento(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS ix_mantenimientos_vehiculo_id
    ON mantenimientos(vehiculo_id);

CREATE INDEX IF NOT EXISTS ix_mantenimientos_tipo_id
    ON mantenimientos(tipo_mantenimiento_id);

CREATE INDEX IF NOT EXISTS ix_mantenimientos_proxima_fecha
    ON mantenimientos(proxima_fecha);

-- ============================================================
-- DOCUMENTOS
-- ============================================================

CREATE TABLE IF NOT EXISTS documentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL,
    tipo_documento_id UUID NOT NULL,
    numero_referencia VARCHAR(80),
    entidad_emisora VARCHAR(120),
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    ruta_archivo VARCHAR(300),
    observaciones TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_documentos_vehiculos
        FOREIGN KEY (vehiculo_id)
        REFERENCES vehiculos(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_documentos_tipos
        FOREIGN KEY (tipo_documento_id)
        REFERENCES tipos_documento(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS ix_documentos_vehiculo_id
    ON documentos(vehiculo_id);

CREATE INDEX IF NOT EXISTS ix_documentos_tipo_id
    ON documentos(tipo_documento_id);

CREATE INDEX IF NOT EXISTS ix_documentos_fecha_vencimiento
    ON documentos(fecha_vencimiento);

-- ============================================================
-- GASTOS
-- ============================================================

CREATE TABLE IF NOT EXISTS gastos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehiculo_id UUID NOT NULL,
    categoria_gasto_id UUID NOT NULL,
    descripcion VARCHAR(200),
    valor NUMERIC(12,2) NOT NULL,
    fecha DATE NOT NULL,
    ruta_soporte VARCHAR(300),
    observaciones TEXT,
    fecha_creacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_gastos_vehiculos
        FOREIGN KEY (vehiculo_id)
        REFERENCES vehiculos(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_gastos_categorias
        FOREIGN KEY (categoria_gasto_id)
        REFERENCES categorias_gasto(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS ix_gastos_vehiculo_id
    ON gastos(vehiculo_id);

CREATE INDEX IF NOT EXISTS ix_gastos_categoria_id
    ON gastos(categoria_gasto_id);

CREATE INDEX IF NOT EXISTS ix_gastos_fecha
    ON gastos(fecha);

-- ============================================================
-- ALERTAS
-- ============================================================

CREATE TABLE IF NOT EXISTS alertas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID,
    vehiculo_id UUID,
    tipo VARCHAR(30) NOT NULL,
    titulo VARCHAR(120) NOT NULL,
    mensaje VARCHAR(250) NOT NULL,
    fecha_alerta TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_lectura TIMESTAMP WITH TIME ZONE,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_alertas_usuarios
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_alertas_vehiculos
        FOREIGN KEY (vehiculo_id)
        REFERENCES vehiculos(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS ix_alertas_usuario_id
    ON alertas(usuario_id);

CREATE INDEX IF NOT EXISTS ix_alertas_vehiculo_id
    ON alertas(vehiculo_id);

CREATE INDEX IF NOT EXISTS ix_alertas_fecha
    ON alertas(fecha_alerta);

-- ============================================================
-- DATOS INICIALES
-- ============================================================

INSERT INTO roles (id, nombre, descripcion, activo)
SELECT gen_random_uuid(), 'PROPIETARIO',
       'Usuario propietario de uno o varios vehiculos.', TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM roles WHERE nombre = 'PROPIETARIO'
);

INSERT INTO roles (id, nombre, descripcion, activo)
SELECT gen_random_uuid(), 'ADMINISTRADOR',
       'Usuario con permisos de administracion.', TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM roles WHERE nombre = 'ADMINISTRADOR'
);

INSERT INTO tipos_vehiculo (id, nombre, descripcion, activo)
SELECT gen_random_uuid(), v.nombre, v.descripcion, TRUE
FROM (
    VALUES
        ('Motocicleta', 'Vehiculo tipo motocicleta'),
        ('Automóvil', 'Vehiculo tipo automovil'),
        ('Camioneta', 'Vehiculo tipo camioneta'),
        ('Van', 'Vehiculo tipo van'),
        ('Camión', 'Vehiculo tipo camion'),
        ('Bus', 'Vehiculo tipo bus'),
        ('Otro', 'Otro tipo de vehiculo')
) AS v(nombre, descripcion)
WHERE NOT EXISTS (
    SELECT 1 FROM tipos_vehiculo t WHERE t.nombre = v.nombre
);

INSERT INTO tipos_mantenimiento
    (id, nombre, categoria, descripcion, activo)
SELECT gen_random_uuid(), v.nombre, v.categoria, v.descripcion, TRUE
FROM (
    VALUES
        ('Cambio de aceite', 'PREVENTIVO', 'Cambio periodico de aceite'),
        ('Cambio de filtros', 'PREVENTIVO', 'Cambio de filtros del vehiculo'),
        ('Revisión de frenos', 'PREVENTIVO', 'Revision preventiva del sistema de frenos'),
        ('Alineación y balanceo', 'PREVENTIVO', 'Alineacion y balanceo'),
        ('Cambio de llantas', 'PREVENTIVO', 'Cambio de llantas'),
        ('Reparación de frenos', 'CORRECTIVO', 'Reparacion del sistema de frenos'),
        ('Reparación eléctrica', 'CORRECTIVO', 'Reparacion del sistema electrico'),
        ('Reparación de motor', 'CORRECTIVO', 'Reparacion de motor'),
        ('Otro preventivo', 'PREVENTIVO', 'Otro mantenimiento preventivo'),
        ('Otro correctivo', 'CORRECTIVO', 'Otro mantenimiento correctivo')
) AS v(nombre, categoria, descripcion)
WHERE NOT EXISTS (
    SELECT 1 FROM tipos_mantenimiento t WHERE t.nombre = v.nombre
);

INSERT INTO tipos_documento (id, nombre, descripcion, activo)
SELECT gen_random_uuid(), v.nombre, v.descripcion, TRUE
FROM (
    VALUES
        ('SOAT', 'Seguro Obligatorio de Accidentes de Transito'),
        ('Revisión técnico-mecánica', 'Revision tecnico-mecanica'),
        ('Seguro', 'Seguro adicional del vehiculo'),
        ('Tarjeta de propiedad', 'Documento de propiedad del vehiculo'),
        ('Otro', 'Otro documento asociado al vehiculo')
) AS v(nombre, descripcion)
WHERE NOT EXISTS (
    SELECT 1 FROM tipos_documento t WHERE t.nombre = v.nombre
);

INSERT INTO categorias_gasto (id, nombre, descripcion, activo)
SELECT gen_random_uuid(), v.nombre, v.descripcion, TRUE
FROM (
    VALUES
        ('Mantenimiento', 'Gastos de mantenimiento'),
        ('Repuestos', 'Compra de repuestos'),
        ('Combustible', 'Combustible'),
        ('Lavado', 'Lavado del vehiculo'),
        ('Peajes', 'Pago de peajes'),
        ('Parqueadero', 'Pago de parqueadero'),
        ('Seguros', 'Seguros del vehiculo'),
        ('Impuestos', 'Impuestos del vehiculo'),
        ('Otros', 'Otros gastos')
) AS v(nombre, descripcion)
WHERE NOT EXISTS (
    SELECT 1 FROM categorias_gasto t WHERE t.nombre = v.nombre
);

-- ============================================================
-- COMPROBACION BASICA
-- ============================================================

SELECT 'roles' AS tabla, COUNT(*) AS registros FROM roles
UNION ALL
SELECT 'tipos_vehiculo', COUNT(*) FROM tipos_vehiculo
UNION ALL
SELECT 'tipos_mantenimiento', COUNT(*) FROM tipos_mantenimiento
UNION ALL
SELECT 'tipos_documento', COUNT(*) FROM tipos_documento
UNION ALL
SELECT 'categorias_gasto', COUNT(*) FROM categorias_gasto;
