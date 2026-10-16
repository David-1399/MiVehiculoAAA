-- ============================================================
-- MiVehiculoAAA
-- 003_promover_usuario_admin.sql
--
-- OPCIONAL.
-- Primero registra un usuario normalmente desde la app.
-- Luego cambia el correo de ejemplo por el correo real que se
-- desea convertir en administrador.
-- ============================================================

UPDATE usuarios
SET rol_id = (
    SELECT id
    FROM roles
    WHERE nombre = 'ADMINISTRADOR'
      AND activo = TRUE
    LIMIT 1
),
fecha_actualizacion = CURRENT_TIMESTAMP
WHERE LOWER(correo) = LOWER('CAMBIAR_CORREO@EJEMPLO.COM');

SELECT
    u.id,
    u.nombres,
    u.apellidos,
    u.correo,
    r.nombre AS rol,
    u.activo
FROM usuarios u
INNER JOIN roles r ON r.id = u.rol_id
WHERE LOWER(u.correo) = LOWER('CAMBIAR_CORREO@EJEMPLO.COM');
