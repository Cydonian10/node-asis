/*======================================================================================================
NOMBRE: 20260804-areas-roles-asignaciones
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Migración de bases existentes para el SPEC 03 (módulos de áreas y roles con asignaciones
          por lote). El canon para instalaciones nuevas vive en database/tables/tablas.sql.

Cambios que aplica en orden:
  1. Crear TVP IntListTableType.
  2. Crear TVP AreaBatchTableType.
  3. Crear tabla RolUnidad.
  4. Copiar datos: un (RolId, UnidadId) por cada fila de Rol; repuntar UsuarioRol.RolId ->
     RolUnidad.RolUnidadId.
  5. Quitar FK UsuarioRol->Rol, columna RolId, y recrear FK UsuarioRol.RolUnidadId -> RolUnidad.
  6. Quitar FK y columna Rol.UnidadId (Rol pasa a catálogo global).
  7. Area.UnidadId INT NOT NULL + FK -> Unidad.
  8. Crear tabla UsuarioArea.
  9. Seed del catálogo Rol (Supervisor, Asistente, Usuario) con IF NOT EXISTS.

El script es re-ejecutable: tipos, tablas y constraints se crean con guardas; el seed es idempotente.

NOTA IMPORTANTE (paso 7): si la BD real ya tiene filas en Area, el ALTER a NOT NULL fallará.
      Pre-poblar UnidadId antes de ejecutar, por ejemplo:
        UPDATE a
        SET a.UnidadId = (SELECT TOP 1 UnidadId FROM Unidad)
        FROM Area a
        WHERE a.UnidadId IS NULL;
      (o asignar la unidad por defecto del negocio). Ejecutar esto ANTES de este script en bases
      con áreas existentes.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/

-- Paso 1: TVP IntListTableType
IF NOT EXISTS (SELECT 1 FROM sys.types WHERE name = 'IntListTableType' AND is_table_type = 1)
BEGIN
    CREATE TYPE dbo.IntListTableType AS TABLE (Value INT NOT NULL);
END
GO

-- Paso 2: TVP AreaBatchTableType
IF NOT EXISTS (SELECT 1 FROM sys.types WHERE name = 'AreaBatchTableType' AND is_table_type = 1)
BEGIN
    CREATE TYPE dbo.AreaBatchTableType AS TABLE (Nombre VARCHAR(200) NOT NULL, Descripcion VARCHAR(255) NULL);
END
GO

-- Paso 3: Tabla RolUnidad
IF OBJECT_ID('dbo.RolUnidad', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RolUnidad
    (
        RolUnidadId INT IDENTITY(1,1) PRIMARY KEY,
        RolId INT NOT NULL,
        UnidadId INT NOT NULL,
        Eliminado BIT DEFAULT 0,
        CreatedAt DATETIME2 DEFAULT GETDATE(),
        UpdatedAt DATETIME2 DEFAULT GETDATE(),
        CreatedBy VARCHAR(200),
        UpdatedBy VARCHAR(200),
        UNIQUE (RolId, UnidadId),
        FOREIGN KEY (RolId) REFERENCES Rol(RolId),
        FOREIGN KEY (UnidadId) REFERENCES Unidad(UnidadId)
    );
END
GO

-- Paso 4a: copiar datos existentes de Rol -> RolUnidad (solo si RolUnidad esta vacia)
IF NOT EXISTS (SELECT 1 FROM dbo.RolUnidad)
   AND EXISTS (SELECT 1 FROM dbo.Rol)
BEGIN
    INSERT INTO dbo.RolUnidad (RolId, UnidadId, CreatedBy, UpdatedBy)
    SELECT RolId, UnidadId, CreatedBy, UpdatedBy
    FROM dbo.Rol;
END
GO

-- Paso 4b: agregar columna RolUnidadId a UsuarioRol (NULL para poder repuntar)
IF COL_LENGTH('dbo.UsuarioRol', 'RolUnidadId') IS NULL
BEGIN
    ALTER TABLE dbo.UsuarioRol ADD RolUnidadId INT NULL;
END
GO

-- Paso 4c: repuntar UsuarioRol.RolId -> RolUnidad.RolUnidadId
IF COL_LENGTH('dbo.UsuarioRol', 'RolUnidadId') IS NOT NULL
   AND COL_LENGTH('dbo.UsuarioRol', 'RolId') IS NOT NULL
   AND EXISTS (SELECT 1 FROM dbo.RolUnidad)
BEGIN
    UPDATE UR
    SET UR.RolUnidadId = RU.RolUnidadId
    FROM dbo.UsuarioRol UR
    INNER JOIN dbo.RolUnidad RU ON RU.RolId = UR.RolId;
END
GO

-- Paso 5a: quitar FK de UsuarioRol a Rol
DECLARE @FK_UsuarioRol_Rol NVARCHAR(255);
SELECT @FK_UsuarioRol_Rol = fk.name
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables t
    ON t.object_id = fk.parent_object_id
INNER JOIN sys.columns c
    ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
WHERE t.name = 'UsuarioRol' AND c.name = 'RolId';

IF @FK_UsuarioRol_Rol IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.UsuarioRol DROP CONSTRAINT ' + @FK_UsuarioRol_Rol);
END
GO

-- Paso 5b: quitar columna RolId y fijar RolUnidadId como NOT NULL
IF COL_LENGTH('dbo.UsuarioRol', 'RolId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.UsuarioRol DROP COLUMN RolId;
END
GO

IF COL_LENGTH('dbo.UsuarioRol', 'RolUnidadId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.UsuarioRol ALTER COLUMN RolUnidadId INT NOT NULL;
END
GO

-- Paso 5c: recrear FK de UsuarioRol a RolUnidad
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_UsuarioRol_RolUnidad')
   AND COL_LENGTH('dbo.UsuarioRol', 'RolUnidadId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.UsuarioRol
        ADD CONSTRAINT FK_UsuarioRol_RolUnidad
        FOREIGN KEY (RolUnidadId) REFERENCES RolUnidad(RolUnidadId);
END
GO

-- Paso 6a: quitar FK de Rol a Unidad
DECLARE @FK_Rol_Unidad NVARCHAR(255);
SELECT @FK_Rol_Unidad = fk.name
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables t
    ON t.object_id = fk.parent_object_id
INNER JOIN sys.columns c
    ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
WHERE t.name = 'Rol' AND c.name = 'UnidadId';

IF @FK_Rol_Unidad IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.Rol DROP CONSTRAINT ' + @FK_Rol_Unidad);
END
GO

-- Paso 6b: quitar columna Rol.UnidadId
IF COL_LENGTH('dbo.Rol', 'UnidadId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Rol DROP COLUMN UnidadId;
END
GO

-- Paso 7a: Area.UnidadId (ver NOTA del encabezado sobre bases con areas existentes)
IF COL_LENGTH('dbo.Area', 'UnidadId') IS NULL
BEGIN
    ALTER TABLE dbo.Area ADD UnidadId INT NOT NULL;
END
GO

-- Paso 7b: FK de Area a Unidad
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Area_Unidad')
   AND COL_LENGTH('dbo.Area', 'UnidadId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Area
        ADD CONSTRAINT FK_Area_Unidad
        FOREIGN KEY (UnidadId) REFERENCES Unidad(UnidadId);
END
GO

-- Paso 8: Tabla UsuarioArea
IF OBJECT_ID('dbo.UsuarioArea', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UsuarioArea
    (
        UsuarioAreaId INT IDENTITY(1,1) PRIMARY KEY,
        UsuarioId INT NOT NULL,
        AreaId INT NOT NULL,
        Eliminado BIT DEFAULT 0,
        CreatedAt DATETIME2 DEFAULT GETDATE(),
        UpdatedAt DATETIME2 DEFAULT GETDATE(),
        CreatedBy VARCHAR(200),
        UpdatedBy VARCHAR(200),
        UNIQUE (UsuarioId, AreaId),
        FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
        FOREIGN KEY (AreaId) REFERENCES Area(AreaId)
    );
END
GO

-- Paso 9: Seed del catalogo Rol (idempotente)
IF NOT EXISTS (SELECT 1 FROM dbo.Rol WHERE Nombre IN ('Supervisor', 'Asistente', 'Usuario'))
BEGIN
    INSERT INTO dbo.Rol (Nombre, Descripcion)
    VALUES
        ('Supervisor', 'Rol de supervisión'),
        ('Asistente', 'Rol de asistente'),
        ('Usuario', 'Rol base de usuario');
END
GO
