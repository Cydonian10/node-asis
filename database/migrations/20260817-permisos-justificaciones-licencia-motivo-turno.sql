/*======================================================================================================
MIGRACION: 20260817-permisos-justificaciones-licencia-motivo-turno.sql
OBJETIVO:
  1. Agregar MotivoId (FK -> Motivo) y TurnoId (FK -> Turno) a Permisos, Justificaciones y Licencia
     para poder verificar a que turno esta ligada cada solicitud.
  2. Eliminar la columna Motivo TEXT (texto libre) de Permisos y Justificaciones; el motivo ahora
     es un catalogo (MotivoId).
Re-ejecutable (guardas sobre COL_LENGTH, sys.foreign_keys y sys.default_constraints).
======================================================================================================*/

-- Agregar columnas MotivoId y TurnoId (NULL-able) a las 3 tablas
IF COL_LENGTH('dbo.Permisos', 'MotivoId') IS NULL
    ALTER TABLE dbo.Permisos ADD MotivoId INT NULL;
GO

IF COL_LENGTH('dbo.Permisos', 'TurnoId') IS NULL
    ALTER TABLE dbo.Permisos ADD TurnoId INT NULL;
GO

IF COL_LENGTH('dbo.Justificaciones', 'MotivoId') IS NULL
    ALTER TABLE dbo.Justificaciones ADD MotivoId INT NULL;
GO

IF COL_LENGTH('dbo.Justificaciones', 'TurnoId') IS NULL
    ALTER TABLE dbo.Justificaciones ADD TurnoId INT NULL;
GO

IF COL_LENGTH('dbo.Licencia', 'MotivoId') IS NULL
    ALTER TABLE dbo.Licencia ADD MotivoId INT NULL;
GO

IF COL_LENGTH('dbo.Licencia', 'TurnoId') IS NULL
    ALTER TABLE dbo.Licencia ADD TurnoId INT NULL;
GO

-- Eliminar columna Motivo TEXT de Permisos y Justificaciones
IF COL_LENGTH('dbo.Permisos', 'Motivo') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Permisos DROP COLUMN Motivo;
END
GO

IF COL_LENGTH('dbo.Justificaciones', 'Motivo') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Justificaciones DROP COLUMN Motivo;
END
GO

-- FKs nuevas para MotivoId
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Permisos_Motivo')
BEGIN
    ALTER TABLE dbo.Permisos ADD CONSTRAINT FK_Permisos_Motivo
        FOREIGN KEY (MotivoId) REFERENCES Motivo(MotivoId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Justificaciones_Motivo')
BEGIN
    ALTER TABLE dbo.Justificaciones ADD CONSTRAINT FK_Justificaciones_Motivo
        FOREIGN KEY (MotivoId) REFERENCES Motivo(MotivoId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Licencia_Motivo')
BEGIN
    ALTER TABLE dbo.Licencia ADD CONSTRAINT FK_Licencia_Motivo
        FOREIGN KEY (MotivoId) REFERENCES Motivo(MotivoId);
END
GO

-- FKs nuevas para TurnoId
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Permisos_Turno')
BEGIN
    ALTER TABLE dbo.Permisos ADD CONSTRAINT FK_Permisos_Turno
        FOREIGN KEY (TurnoId) REFERENCES Turno(TurnoId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Justificaciones_Turno')
BEGIN
    ALTER TABLE dbo.Justificaciones ADD CONSTRAINT FK_Justificaciones_Turno
        FOREIGN KEY (TurnoId) REFERENCES Turno(TurnoId);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Licencia_Turno')
BEGIN
    ALTER TABLE dbo.Licencia ADD CONSTRAINT FK_Licencia_Turno
        FOREIGN KEY (TurnoId) REFERENCES Turno(TurnoId);
END
GO