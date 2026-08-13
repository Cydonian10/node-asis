/*======================================================================================================
MIGRACION: 20260813-usuario-area-multi.sql
OBJETIVO:
  1. Crear la tabla UsuarioArea (usuario puede tener un area por unidad).
  2. Migrar los datos actuales de Usuario (AreaId, EsSupervisor) a UsuarioArea.
  3. Seed idempotente de SyncUnidad y SyncUsuarios de ejemplo.
  4. Crear el TVP SyncUsuarioBatchTableType para el batch de asignacion.
Re-ejecutable (guardas).
======================================================================================================*/

-- 1) Tabla UsuarioArea
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'UsuarioArea')
BEGIN
    CREATE TABLE UsuarioArea
    (
        UsuarioAreaId INT IDENTITY(1,1) PRIMARY KEY,
        UsuarioId INT NOT NULL,
        AreaId INT NOT NULL,
        EsSupervisor BIT DEFAULT 0,
        Eliminado BIT DEFAULT 0,
        CreatedAt DATETIME2 DEFAULT GETDATE(),
        UpdatedAt DATETIME2 DEFAULT GETDATE(),
        UNIQUE (UsuarioId, AreaId),
        FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
        FOREIGN KEY (AreaId) REFERENCES Area(AreaId)
    );
END
GO

-- 2) Migrar datos actuales de Usuario -> UsuarioArea
IF NOT EXISTS (SELECT 1 FROM UsuarioArea)
BEGIN
    INSERT INTO UsuarioArea (UsuarioId, AreaId, EsSupervisor, Eliminado)
    SELECT UsuarioId, AreaId, EsSupervisor, Eliminado
    FROM Usuario
    WHERE Eliminado = 0;
END
GO

-- 3) Seed idempotente: SyncUnidad de ejemplo (Colegio / Pre-Academia / Academia)
IF NOT EXISTS (SELECT 1 FROM SyncUnidad WHERE SyncUnidadId = 10)
    INSERT INTO SyncUnidad (SyncUnidadId, Codigo, Nombre) VALUES (10, 'COL', 'Colegio');
GO
IF NOT EXISTS (SELECT 1 FROM SyncUnidad WHERE SyncUnidadId = 11)
    INSERT INTO SyncUnidad (SyncUnidadId, Codigo, Nombre) VALUES (11, 'PRE', 'Pre-Academia');
GO
IF NOT EXISTS (SELECT 1 FROM SyncUnidad WHERE SyncUnidadId = 12)
    INSERT INTO SyncUnidad (SyncUnidadId, Codigo, Nombre) VALUES (12, 'ACA', 'Academia');
GO

-- Seed idempotente: SyncUsuarios de ejemplo
IF NOT EXISTS (SELECT 1 FROM SyncUsuarios WHERE SyncUsuarioId = 2001)
    INSERT INTO SyncUsuarios (SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
    VALUES (2001, 'jperez', 'Juan', 'Perez', 'CO', '20010001');
GO
IF NOT EXISTS (SELECT 1 FROM SyncUsuarios WHERE SyncUsuarioId = 2002)
    INSERT INTO SyncUsuarios (SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
    VALUES (2002, 'mlopez', 'Maria', 'Lopez', 'CO', '20020002');
GO
IF NOT EXISTS (SELECT 1 FROM SyncUsuarios WHERE SyncUsuarioId = 2003)
    INSERT INTO SyncUsuarios (SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
    VALUES (2003, 'cramirez', 'Carlos', 'Ramirez', 'AL', '20030003');
GO

-- 4) TVP para el batch de asignacion (SyncUsuarioId NULL = crear el sync)
IF NOT EXISTS (SELECT 1 FROM sys.types WHERE name = 'SyncUsuarioBatchTableType' AND is_table_type = 1)
    EXEC(N'CREATE TYPE dbo.SyncUsuarioBatchTableType AS TABLE
          (SyncUsuarioId INT NULL, Usuario VARCHAR(200) NULL, Nombres VARCHAR(200) NULL,
           Apellidos VARCHAR(200) NULL, Tipo VARCHAR(50) NULL, Dni VARCHAR(20) NULL)');
GO
