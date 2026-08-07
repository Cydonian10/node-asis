/*======================================================================================================
NOMBRE: 20260805-horario-sin-unidadid
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Migración de bases existentes para el SPEC 05 (módulo de horarios). Quita UnidadId de
          Horario (la unidad se deriva de Area.UnidadId, igual que SPEC 04), deja AreaId NOT NULL
          y seedea el catálogo de 7 días (Dia).

Cambios que aplica en orden:
  1. Quitar FK Horario->Unidad, constraints DEFAULT e indices sobre UnidadId, y la columna UnidadId.
  2. Asegurar AreaId NOT NULL en Horario.
  3. Seed del catálogo Dia (Lunes..Domingo) con IF NOT EXISTS.

El script es re-ejecutable: columnas y constraints se crean/eliminan con guardas; el seed es idempotente.

NOTA IMPORTANTE (paso 2): si en algún entorno Horario quedó con filas de AreaId NULL, el ALTER a
      NOT NULL fallará. Pre-poblar AreaId antes de ejecutar en ese caso.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/

-- Paso 1a: quitar FK de Horario a Unidad
DECLARE @FK_Horario_Unidad NVARCHAR(255);
SELECT @FK_Horario_Unidad = fk.name
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fkc.constraint_object_id = fk.object_id
INNER JOIN sys.tables t
    ON t.object_id = fk.parent_object_id
INNER JOIN sys.columns c
    ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
WHERE t.name = 'Horario' AND c.name = 'UnidadId';

IF @FK_Horario_Unidad IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.Horario DROP CONSTRAINT ' + @FK_Horario_Unidad);
END
GO

-- Paso 1b: quitar constraints DEFAULT sobre Horario.UnidadId (si los hay, bloquean el DROP COLUMN)
IF COL_LENGTH('dbo.Horario', 'UnidadId') IS NOT NULL
BEGIN
    DECLARE @SQL NVARCHAR(MAX) = N'';
    SELECT @SQL += 'ALTER TABLE dbo.Horario DROP CONSTRAINT '
        + QUOTENAME(dc.name) + ';' + CHAR(10)
    FROM sys.default_constraints dc
    INNER JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
    WHERE dc.parent_object_id = OBJECT_ID('dbo.Horario') AND c.name = 'UnidadId';

    IF @SQL <> N''
    BEGIN
        EXEC sp_executesql @SQL;
    END
END
GO

-- Paso 1c: quitar indices no unicos sobre Horario.UnidadId (si los hay, bloquean el DROP COLUMN)
IF COL_LENGTH('dbo.Horario', 'UnidadId') IS NOT NULL
BEGIN
    DECLARE @SQLIdx NVARCHAR(MAX) = N'';
    SELECT @SQLIdx += 'DROP INDEX ' + QUOTENAME(i.name)
        + ' ON dbo.Horario;' + CHAR(10)
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    INNER JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE i.object_id = OBJECT_ID('dbo.Horario')
      AND c.name = 'UnidadId'
      AND i.is_primary_key = 0
      AND i.is_unique_constraint = 0;

    IF @SQLIdx <> N''
    BEGIN
        EXEC sp_executesql @SQLIdx;
    END
END
GO

-- Paso 1d: quitar columna UnidadId de Horario
IF COL_LENGTH('dbo.Horario', 'UnidadId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Horario DROP COLUMN UnidadId;
END
GO

-- Paso 2: asegurar AreaId NOT NULL en Horario
IF COL_LENGTH('dbo.Horario', 'AreaId') IS NOT NULL
BEGIN
    DECLARE @Nullable BIT;
    SELECT @Nullable = c.is_nullable
    FROM sys.columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    WHERE t.name = 'Horario' AND c.name = 'AreaId';

    IF @Nullable = 1
    BEGIN
        ALTER TABLE dbo.Horario ALTER COLUMN AreaId INT NOT NULL;
    END
END
GO

-- Paso 3: seed del catalogo Dia (idempotente)
IF NOT EXISTS (SELECT 1 FROM dbo.Dia)
BEGIN
    INSERT INTO dbo.Dia (Nombre, Abreviatura, Orden)
    VALUES
        ('Lunes', 'Lun', 1),
        ('Martes', 'Mar', 2),
        ('Miercoles', 'Mie', 3),
        ('Jueves', 'Jue', 4),
        ('Viernes', 'Vie', 5),
        ('Sabado', 'Sab', 6),
        ('Domingo', 'Dom', 7);
END
GO
