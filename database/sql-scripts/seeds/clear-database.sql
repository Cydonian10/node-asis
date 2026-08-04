USE API_SCAP_DB;
GO

DECLARE @sql NVARCHAR(MAX) = '';

-- 1. Foreign Keys
SELECT @sql += 
    'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) +
    ' DROP CONSTRAINT ' + QUOTENAME(fk.name) + ';' + CHAR(13)
FROM sys.foreign_keys fk
  JOIN sys.tables t ON fk.parent_object_id = t.object_id
  JOIN sys.schemas s ON t.schema_id = s.schema_id;

EXEC sp_executesql @sql;
SET @sql = '';

-- 2. Views
SELECT @sql += 
    'DROP VIEW ' + QUOTENAME(s.name) + '.' + QUOTENAME(v.name) + ';' + CHAR(13)
FROM sys.views v
  JOIN sys.schemas s ON v.schema_id = s.schema_id;

EXEC sp_executesql @sql;
SET @sql = '';

-- 3. Functions
SELECT @sql += 
    'DROP FUNCTION ' + QUOTENAME(s.name) + '.' + QUOTENAME(f.name) + ';' + CHAR(13)
FROM sys.objects f
  JOIN sys.schemas s ON f.schema_id = s.schema_id
WHERE f.type IN ('FN','IF','TF');

EXEC sp_executesql @sql;
SET @sql = '';

-- 4. Procedures
SELECT @sql += 
    'DROP PROCEDURE ' + QUOTENAME(s.name) + '.' + QUOTENAME(p.name) + ';' + CHAR(13)
FROM sys.procedures p
  JOIN sys.schemas s ON p.schema_id = s.schema_id;

EXEC sp_executesql @sql;
SET @sql = '';

-- 5. Tables
SELECT @sql += 
    'DROP TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ';' + CHAR(13)
FROM sys.tables t
  JOIN sys.schemas s ON t.schema_id = s.schema_id;

EXEC sp_executesql @sql;
SET @sql = '';

-- 6. Sequences
SELECT @sql += 
    'DROP SEQUENCE ' + QUOTENAME(s.name) + '.' + QUOTENAME(seq.name) + ';' + CHAR(13)
FROM sys.sequences seq
  JOIN sys.schemas s ON seq.schema_id = s.schema_id;

EXEC sp_executesql @sql;
SET @sql = '';

-- 7. Types
SELECT @sql += 
    'DROP TYPE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ';' + CHAR(13)
FROM sys.types t
  JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.is_user_defined = 1;

EXEC sp_executesql @sql;