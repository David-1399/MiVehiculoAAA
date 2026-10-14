ALTER TABLE gastos
ADD COLUMN IF NOT EXISTS mantenimiento_id UUID NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_gastos_mantenimiento'
    ) THEN
        ALTER TABLE gastos
        ADD CONSTRAINT fk_gastos_mantenimiento
        FOREIGN KEY (mantenimiento_id)
        REFERENCES mantenimientos(id)
        ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS ix_gastos_mantenimiento_id
ON gastos(mantenimiento_id);