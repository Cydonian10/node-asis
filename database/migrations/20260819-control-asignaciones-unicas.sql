/*======================================================================================================
NOMBRE: Migracion - Asignaciones unicas de control
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Asegurar una sola asignacion activa de control por area, unidad y usuario.
          1. Valores numericos de [Control] NOT NULL.
          2. Agregar CreatedBy a ControlUnidad (consistencia con ControlArea/ControlUsuario).
          3. Quitar constraints UNIQUE (ControlId, objetivo) y reemplazarlos por indices
             unicos filtrados sobre el objetivo con Eliminado = 0.
          4. Limpiar duplicados activos previos antes de crear los indices.
======================================================================================================*/
USE API_SCAP_DB;
GO

-- 1) [Control]: garantizar valores no nulos antes de hacer NOT NULL
UPDATE [Control] SET Tolerancia = 0 WHERE Tolerancia IS NULL;
UPDATE [Control] SET LimiteFalta = 0 WHERE LimiteFalta IS NULL;
UPDATE [Control] SET LimiteTardanza = 0 WHERE LimiteTardanza IS NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.[Control]') AND name = 'Tolerancia' AND is_nullable = 1)
    ALTER TABLE [Control] ALTER COLUMN Tolerancia INT NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.[Control]') AND name = 'LimiteFalta' AND is_nullable = 1)
    ALTER TABLE [Control] ALTER COLUMN LimiteFalta INT NOT NULL;
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.[Control]') AND name = 'LimiteTardanza' AND is_nullable = 1)
    ALTER TABLE [Control] ALTER COLUMN LimiteTardanza INT NOT NULL;
GO

-- 2) ControlUnidad: agregar CreatedBy
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ControlUnidad') AND name = 'CreatedBy')
    ALTER TABLE ControlUnidad ADD CreatedBy INT NOT NULL DEFAULT 0;
GO

-- 3) Quitar constraints UNIQUE por combinacion (ControlId, objetivo)
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql = @sql + 'ALTER TABLE dbo.' + QUOTENAME(t.name) + ' DROP CONSTRAINT ' + QUOTENAME(i.name) + ';' + CHAR(10)
FROM sys.indexes i
INNER JOIN sys.tables t ON t.object_id = i.object_id
WHERE t.name IN ('ControlUnidad', 'ControlUsuario')
  AND i.is_unique_constraint = 1;
IF @sql <> N''
    EXEC sp_executesql @sql;
GO

-- 4) Limpiar duplicados activos previos (conservar la fila mas antigua)
UPDATE CA
SET CA.Eliminado = 1, CA.UpdatedAt = GETDATE()
FROM ControlArea CA
WHERE CA.Eliminado = 0
  AND EXISTS (
      SELECT 1 FROM ControlArea CA2
      WHERE CA2.AreaId = CA.AreaId
        AND CA2.Eliminado = 0
        AND CA2.ControlAreaId < CA.ControlAreaId
  );
GO

UPDATE CUN
SET CUN.Eliminado = 1, CUN.UpdatedAt = GETDATE()
FROM ControlUnidad CUN
WHERE CUN.Eliminado = 0
  AND EXISTS (
      SELECT 1 FROM ControlUnidad CUN2
      WHERE CUN2.UnidadId = CUN.UnidadId
        AND CUN2.Eliminado = 0
        AND CUN2.ControlUnidadId < CUN.ControlUnidadId
  );
GO

UPDATE CUS
SET CUS.Eliminado = 1, CUS.UpdatedAt = GETDATE()
FROM ControlUsuario CUS
WHERE CUS.Eliminado = 0
  AND EXISTS (
      SELECT 1 FROM ControlUsuario CUS2
      WHERE CUS2.UsuarioId = CUS.UsuarioId
        AND CUS2.Eliminado = 0
        AND CUS2.ControlUsuarioId < CUS.ControlUsuarioId
  );
GO

-- 5) Indices unicos filtrados por objetivo activo
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ControlArea_Active_Area' AND object_id = OBJECT_ID('dbo.ControlArea'))
    CREATE UNIQUE INDEX UX_ControlArea_Active_Area
        ON ControlArea (AreaId)
        WHERE Eliminado = 0;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ControlUnidad_Active_Unidad' AND object_id = OBJECT_ID('dbo.ControlUnidad'))
    CREATE UNIQUE INDEX UX_ControlUnidad_Active_Unidad
        ON ControlUnidad (UnidadId)
        WHERE Eliminado = 0;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_ControlUsuario_Active_Usuario' AND object_id = OBJECT_ID('dbo.ControlUsuario'))
    CREATE UNIQUE INDEX UX_ControlUsuario_Active_Usuario
        ON ControlUsuario (UsuarioId)
        WHERE Eliminado = 0;
GO