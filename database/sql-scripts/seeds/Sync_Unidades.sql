USE API_SCAP_DB;
GO

-- Seed de prueba: unidades en SyncUnidad para probar la migración a Unidad.
-- Columnas: SyncUnidadId, Codigo, Nombre, Activo
INSERT INTO SyncUnidad (SyncUnidadId, Codigo, Nombre, Activo)
VALUES
    (1,  'UO1', 'Colegio',      1),
    (2,  'U02', 'Pre Academia', 1),
    (3,  'U03', 'Academia',     1);
GO

SELECT * FROM SyncUnidad;
GO
