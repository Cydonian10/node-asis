/*======================================================================================================
MIGRACION: 20260821-asistencia-marcaciones-terminal-pendiente.sql
OBJETIVO: Relacionar terminales biometricos, registrar tardanza, crear Pendiente y asegurar unicidad.
======================================================================================================*/
IF COL_LENGTH('dbo.Biometrico', 'TerminalId') IS NULL
BEGIN
    ALTER TABLE dbo.Biometrico ADD TerminalId INT NULL;

    -- Los dispositivos heredados quedan identificados por su clave local hasta configurarlos.
    UPDATE dbo.Biometrico SET TerminalId = BiometricoId WHERE TerminalId IS NULL;
    ALTER TABLE dbo.Biometrico ALTER COLUMN TerminalId INT NOT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Biometrico') AND name = N'UX_Biometrico_Active_TerminalId')
BEGIN
    CREATE UNIQUE INDEX UX_Biometrico_Active_TerminalId ON dbo.Biometrico (TerminalId) WHERE Eliminado = 0;
END
GO

IF COL_LENGTH('dbo.Asistencia', 'MinutosTarde') IS NULL
BEGIN
    ALTER TABLE dbo.Asistencia ADD MinutosTarde INT NOT NULL CONSTRAINT DF_Asistencia_MinutosTarde DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.EstadoAsistencia WHERE Nombre = 'Pendiente')
BEGIN
    INSERT INTO dbo.EstadoAsistencia (Nombre, CreatedBy, UpdatedBy) VALUES ('Pendiente', 0, 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Asistencia') AND name = N'UX_Asistencia_UsuarioFechaTurno')
BEGIN
    CREATE UNIQUE INDEX UX_Asistencia_UsuarioFechaTurno ON dbo.Asistencia (UsuarioId, Fecha, turnoId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AsistenciaMarcacion') AND name = N'UX_AsistenciaMarcacion_Marcacion')
BEGIN
    CREATE UNIQUE INDEX UX_AsistenciaMarcacion_Marcacion ON dbo.AsistenciaMarcacion (MarcacionId);
END
GO
