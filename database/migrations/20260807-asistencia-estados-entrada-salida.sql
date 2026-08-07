/*======================================================================================================
MIGRACION: 20260807-asistencia-estados-entrada-salida.sql
OBJETIVO: 
  1. Seed de EstadoAsistencia con los 11 valores.
  2. Asistencia: reemplazar EstadoAsistenciaId INT por EstadoAsistenciaEntradaId + EstadoAsistenciaSalidaId,
     agregar ResultadoAsistencia VARCHAR(50) y eliminar TipoAsistencia.
Re-ejecutable (guardas sobre sys.columns y sys.foreign_keys).
======================================================================================================*/
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'Asistio')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('Asistio', 0, 0);
GO
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'Falta')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('Falta', 0, 0);
GO
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'Tarde')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('Tarde', 0, 0);
GO
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'SalidaAnticipada')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('SalidaAnticipada', 0, 0);
GO
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'SinMarcacionEntrada')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('SinMarcacionEntrada', 0, 0);
GO
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'SinMarcacionSalida')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('SinMarcacionSalida', 0, 0);
GO
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'Justificado')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('Justificado', 0, 0);
GO
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'Vacaciones')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('Vacaciones', 0, 0);
GO
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'VigenciaVencida')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('VigenciaVencida', 0, 0);
GO
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'Permiso')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('Permiso', 0, 0);
GO
IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE Nombre = 'Licencia')
    INSERT INTO EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('Licencia', 0, 0);
GO

-- Columna ResultadoAsistencia
IF COL_LENGTH('dbo.Asistencia', 'ResultadoAsistencia') IS NULL
BEGIN
    ALTER TABLE dbo.Asistencia ADD ResultadoAsistencia VARCHAR(50) NULL;
END
GO

-- Columna EstadoAsistenciaEntradaId
IF COL_LENGTH('dbo.Asistencia', 'EstadoAsistenciaEntradaId') IS NULL
BEGIN
    ALTER TABLE dbo.Asistencia ADD EstadoAsistenciaEntradaId INT NULL;
END
GO

-- Columna EstadoAsistenciaSalidaId
IF COL_LENGTH('dbo.Asistencia', 'EstadoAsistenciaSalidaId') IS NULL
BEGIN
    ALTER TABLE dbo.Asistencia ADD EstadoAsistenciaSalidaId INT NULL;
END
GO

-- Soltar FK de EstadoAsistenciaId si existe
IF EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID('dbo.Asistencia')
      AND name = 'FK__Asistencia__EstadoAsistenciaId'
)
BEGIN
    ALTER TABLE dbo.Asistencia DROP CONSTRAINT FK__Asistencia__EstadoAsistenciaId;
END
GO

-- Soltar cualquier FK restante sobre EstadoAsistenciaId (por nombre dinamico)
DECLARE @fkName NVARCHAR(255);
SELECT @fkName = fk.name
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.columns c ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
WHERE fk.parent_object_id = OBJECT_ID('dbo.Asistencia')
  AND c.name = 'EstadoAsistenciaId';
IF @fkName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.Asistencia DROP CONSTRAINT ' + QUOTENAME(@fkName));
END
GO

-- Eliminar columna EstadoAsistenciaId
IF COL_LENGTH('dbo.Asistencia', 'EstadoAsistenciaId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Asistencia DROP COLUMN EstadoAsistenciaId;
END
GO

-- Eliminar columna TipoAsistencia
IF COL_LENGTH('dbo.Asistencia', 'TipoAsistencia') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Asistencia DROP COLUMN TipoAsistencia;
END
GO

-- FKs nuevas
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Asistencia_EstadoEntrada'
)
BEGIN
    ALTER TABLE dbo.Asistencia ADD CONSTRAINT FK_Asistencia_EstadoEntrada
        FOREIGN KEY (EstadoAsistenciaEntradaId) REFERENCES EstadoAsistencia(EstadoAsistenciaId);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Asistencia_EstadoSalida'
)
BEGIN
    ALTER TABLE dbo.Asistencia ADD CONSTRAINT FK_Asistencia_EstadoSalida
        FOREIGN KEY (EstadoAsistenciaSalidaId) REFERENCES EstadoAsistencia(EstadoAsistenciaId);
END
GO
