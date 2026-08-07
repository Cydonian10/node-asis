/*======================================================================================================
MIGRACION: 20260807-salida-turno-dia-sin-fecha.sql
OBJETIVO: Quitar la columna Fecha de SalidaTurnoDia. La salida de turno extendido es un dia de la
          semana (DiaId), no una fecha puntual. Re-ejecutable (guard sobre sys.columns).
======================================================================================================*/
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.SalidaTurnoDia')
        AND name = 'Fecha'
)
BEGIN
    ALTER TABLE dbo.SalidaTurnoDia DROP COLUMN Fecha;
END
GO
