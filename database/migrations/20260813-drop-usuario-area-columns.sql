/*======================================================================================================
MIGRACION: 20260813-drop-usuario-area-columns.sql
OBJETIVO: Eliminar las columnas AreaId y EsSupervisor de la tabla Usuario (ahora viven en UsuarioArea).
          CORRER SOLO DESPUES de desplegar los SPs actualizados (modelo multi-area).
Re-ejecutable (guardas sobre sys.columns, sys.foreign_keys y sys.default_constraints).
======================================================================================================*/

-- Soltar FKs y constraints DEFAULT que dependen de las columnas (por nombre dinamico)
DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = @sql + 'ALTER TABLE dbo.Usuario DROP CONSTRAINT ' + QUOTENAME(fk.name) + ';'
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.columns c ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
WHERE fk.parent_object_id = OBJECT_ID('dbo.Usuario')
  AND c.name IN ('AreaId', 'EsSupervisor');

SELECT @sql = @sql + 'ALTER TABLE dbo.Usuario DROP CONSTRAINT ' + QUOTENAME(dc.name) + ';'
FROM sys.default_constraints dc
INNER JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
WHERE dc.parent_object_id = OBJECT_ID('dbo.Usuario')
  AND c.name IN ('AreaId', 'EsSupervisor');

IF @sql <> ''
BEGIN
    EXEC sp_executesql @sql;
END
GO

-- Eliminar columna AreaId
IF COL_LENGTH('dbo.Usuario', 'AreaId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Usuario DROP COLUMN AreaId;
END
GO

-- Eliminar columna EsSupervisor
IF COL_LENGTH('dbo.Usuario', 'EsSupervisor') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Usuario DROP COLUMN EsSupervisor;
END
GO
