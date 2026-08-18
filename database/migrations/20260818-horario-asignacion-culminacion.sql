/*======================================================================================================
MIGRACION: 20260818-horario-asignacion-culminacion.sql
OBJETIVO: Agregar la columna Culminacion (BIT) a HorarioAsignacion para marcar un horario
          como culminado (Culminacion = 1). Solo se permite asignar un nuevo horario al usuario
          cuando todas sus asignaciones previas estan culminadas.
Re-ejecutable (guardas).
======================================================================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.HorarioAsignacion') AND name = 'Culminacion'
)
BEGIN
    ALTER TABLE HorarioAsignacion ADD Culminacion BIT NOT NULL DEFAULT 0;
END
GO
