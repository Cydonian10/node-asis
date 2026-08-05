/*======================================================================================================
NOMBRE: 20260805-usuario-esSupervisor-sin-roles
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Migración de bases existentes para el SPEC 04 (usuario con área y esSupervisor, sin roles).
          El canon para instalaciones nuevas vive en database/tables/tablas.sql.

Cambios que aplica en orden:
  1. Agregar columna EsSupervisor BIT DEFAULT 0 a Usuario.
  2. Quitar FK Usuario->Rol y columna RolId de Usuario.
  3. Quitar FK Usuario->Unidad y columna UnidadId de Usuario.
  4. Agregar columna AreaId a Usuario si no existe, pre-poblar con un area por defecto si hay filas
     y hay areas, asegurar NOT NULL y agregar FK Usuario->Area.
  5. Drop de tablas con guardas, en orden de dependencias: UsuarioRol, UsuarioArea, UsuarioUnidad,
     RolUnidad, Rol (cada una soltando sus FKs).

El script es re-ejecutable: columnas y constraints se crean/eliminan con guardas.

NOTA IMPORTANTE (paso 4): si la BD real viene de SPEC 03 (Usuario sin AreaId, areas via UsuarioArea),
      la columna se agrega con este paso. Si existen filas de Usuario y no hay areas para pre-poblar,
      el ALTER a NOT NULL fallara; en ese caso pre-poblar AreaId manualmente antes de ejecutar.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/

-- Paso 1: EsSupervisor en Usuario
IF COL_LENGTH('dbo.Usuario', 'EsSupervisor') IS NULL
BEGIN
    ALTER TABLE dbo.Usuario ADD EsSupervisor BIT DEFAULT 0;
END
GO

-- Paso 2a: quitar FK de Usuario a Rol
DECLARE @FK_Usuario_Rol NVARCHAR(255);
SELECT @FK_Usuario_Rol = fk.name
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables t
    ON t.object_id = fk.parent_object_id
INNER JOIN sys.columns c
    ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
WHERE t.name = 'Usuario' AND c.name = 'RolId';

IF @FK_Usuario_Rol IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.Usuario DROP CONSTRAINT ' + @FK_Usuario_Rol);
END
GO

-- Paso 2b: quitar columna RolId de Usuario
IF COL_LENGTH('dbo.Usuario', 'RolId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Usuario DROP COLUMN RolId;
END
GO

-- Paso 3a: quitar FK de Usuario a Unidad
DECLARE @FK_Usuario_Unidad NVARCHAR(255);
SELECT @FK_Usuario_Unidad = fk.name
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables t
    ON t.object_id = fk.parent_object_id
INNER JOIN sys.columns c
    ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
WHERE t.name = 'Usuario' AND c.name = 'UnidadId';

IF @FK_Usuario_Unidad IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.Usuario DROP CONSTRAINT ' + @FK_Usuario_Unidad);
END
GO

-- Paso 3b: quitar columna UnidadId de Usuario
IF COL_LENGTH('dbo.Usuario', 'UnidadId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Usuario DROP COLUMN UnidadId;
END
GO

-- Paso 4a: agregar columna AreaId a Usuario si no existe (nullable para poder pre-poblar)
IF COL_LENGTH('dbo.Usuario', 'AreaId') IS NULL
BEGIN
    ALTER TABLE dbo.Usuario ADD AreaId INT NULL;
END
GO

-- Paso 4b: pre-poblar AreaId con un area por defecto si hay usuarios sin area y existen areas
IF COL_LENGTH('dbo.Usuario', 'AreaId') IS NOT NULL
   AND EXISTS (SELECT 1 FROM Usuario WHERE AreaId IS NULL)
   AND EXISTS (SELECT 1 FROM Area)
BEGIN
    UPDATE Usuario
    SET AreaId = (SELECT TOP 1 AreaId FROM Area WHERE Eliminado = 0)
    WHERE AreaId IS NULL;
END
GO

-- Paso 4c: asegurar AreaId NOT NULL en Usuario
IF COL_LENGTH('dbo.Usuario', 'AreaId') IS NOT NULL
BEGIN
    DECLARE @Nullable BIT;
    SELECT @Nullable = c.is_nullable
    FROM sys.columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    WHERE t.name = 'Usuario' AND c.name = 'AreaId';

    IF @Nullable = 1
    BEGIN
        ALTER TABLE dbo.Usuario ALTER COLUMN AreaId INT NOT NULL;
    END
END
GO

-- Paso 4d: agregar FK de Usuario a Area si no existe
IF COL_LENGTH('dbo.Usuario', 'AreaId') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM sys.foreign_keys fk
       INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
       INNER JOIN sys.columns c ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
       WHERE fk.parent_object_id = OBJECT_ID('dbo.Usuario')
         AND c.name = 'AreaId'
   )
BEGIN
    ALTER TABLE dbo.Usuario
        ADD CONSTRAINT FK_Usuario_Area
        FOREIGN KEY (AreaId) REFERENCES Area(AreaId);
END
GO

-- Paso 5a: soltar todas las FKs que referencian a las tablas a eliminar (padre o referenciado)
DECLARE @dropFk NVARCHAR(MAX) = N'';
SELECT @dropFk += 'ALTER TABLE '
    + QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id))
    + '.' + QUOTENAME(OBJECT_NAME(fk.parent_object_id))
    + ' DROP CONSTRAINT ' + QUOTENAME(fk.name) + ';' + CHAR(10)
FROM sys.foreign_keys fk
WHERE OBJECT_NAME(fk.parent_object_id) IN ('UsuarioRol', 'UsuarioArea', 'UsuarioUnidad', 'RolUnidad', 'Rol')
   OR OBJECT_NAME(fk.referenced_object_id) IN ('UsuarioRol', 'UsuarioArea', 'UsuarioUnidad', 'RolUnidad', 'Rol');

IF @dropFk <> N''
BEGIN
    EXEC sp_executesql @dropFk;
END
GO

-- Paso 5b: drop de las tablas sin uso, en orden de dependencias
IF OBJECT_ID('dbo.UsuarioRol', 'U') IS NOT NULL DROP TABLE dbo.UsuarioRol;
GO
IF OBJECT_ID('dbo.UsuarioArea', 'U') IS NOT NULL DROP TABLE dbo.UsuarioArea;
GO
IF OBJECT_ID('dbo.UsuarioUnidad', 'U') IS NOT NULL DROP TABLE dbo.UsuarioUnidad;
GO
IF OBJECT_ID('dbo.RolUnidad', 'U') IS NOT NULL DROP TABLE dbo.RolUnidad;
GO
IF OBJECT_ID('dbo.Rol', 'U') IS NOT NULL DROP TABLE dbo.Rol;
GO
