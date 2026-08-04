USE API_SCAP_DB;
GO

-- Seed de prueba: unidades en SyncUnidad para probar la migración a Unidad.
-- Columnas: SyncUnidadId, Codigo, Nombre
INSERT INTO SyncUnidad (SyncUnidadId, Codigo, Nombre)
SELECT V.SyncUnidadId, V.Codigo, V.Nombre
FROM (VALUES
    (1, 'UO1', 'Colegio'),
    (2, 'U02', 'Pre Academia'),
    (3, 'U03', 'Academia')
) V(SyncUnidadId, Codigo, Nombre)
WHERE NOT EXISTS (
    SELECT 1 FROM SyncUnidad S WHERE S.SyncUnidadId = V.SyncUnidadId
);
GO

SELECT * FROM SyncUnidad;
GO
