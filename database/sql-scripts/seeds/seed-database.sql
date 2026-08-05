USE API_SCAP_DB;
GO

/*
  Seed compatible con database/tables/tablas.sql (SPEC 04: usuario con area y esSupervisor, sin roles).
  Orden: datos sincronizados -> unidades -> areas -> usuarios asignados a area.
  Puede ejecutarse despues de clear-database.sql y de crear las tablas.
*/

INSERT INTO SyncUnidad (SyncUnidadId, Codigo, Nombre)
SELECT V.SyncUnidadId, V.Codigo, V.Nombre
FROM (VALUES
    (1, 'UO1', 'Colegio'),
    (2, 'UO2', 'Pre Academia'),
    (3, 'UO3', 'Academia')
) V(SyncUnidadId, Codigo, Nombre)
WHERE NOT EXISTS (
    SELECT 1 FROM SyncUnidad S WHERE S.SyncUnidadId = V.SyncUnidadId
);
GO

INSERT INTO SyncUsuarios (SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
SELECT V.SyncUsuarioId, V.Usuario, V.Nombres, V.Apellidos, V.Tipo, V.Dni
FROM (VALUES
    (1001, 'jperez',   'Juan',    'Perez',   'CO', '12345678'),
    (1002, 'mlopez',   'Maria',   'Lopez',   'CO', '23456789'),
    (1003, 'cramirez', 'Carlos',  'Ramirez', 'AL', '34567890'),
    (1004, 'atorres',  'Ana',     'Torres',  'CO', '45678901'),
    (1005, 'lflores',  'Luis',    'Flores',  'AL', '56789012'),
    (1006, 'rcastro',  'Rosa',    'Castro',  'CO', '67890123'),
    (1007, 'dmendoza', 'Diego',   'Mendoza', 'AL', '78901234'),
    (1008, 'nvargas',  'Natalia', 'Vargas',  'CO', '89012345'),
    (1009, 'projas',   'Pedro',   'Rojas',   'AL', '90123456'),
    (1010, 'squiroz',  'Sofia',   'Quiroz',  'CO', '01234567')
) V(SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
WHERE NOT EXISTS (
    SELECT 1 FROM SyncUsuarios S WHERE S.SyncUsuarioId = V.SyncUsuarioId
);
GO

INSERT INTO Unidad (SyncUnidadId, HorasLaborales, HorasLaboralesTotales)
SELECT S.SyncUnidadId, 8, 40
FROM SyncUnidad S
WHERE NOT EXISTS (
    SELECT 1 FROM Unidad U WHERE U.SyncUnidadId = S.SyncUnidadId
);
GO

INSERT INTO Area (UnidadId, Nombre, Descripcion, CreatedBy, UpdatedBy)
SELECT U.UnidadId, V.Nombre, V.Descripcion, 'seed', 'seed'
FROM Unidad U
CROSS APPLY (VALUES
    ('Administracion', 'Area administrativa'),
    ('Operaciones', 'Area operativa')
) V(Nombre, Descripcion)
WHERE NOT EXISTS (
    SELECT 1
    FROM Area A
    WHERE A.UnidadId = U.UnidadId
      AND A.Nombre = V.Nombre
);
GO

-- Los usuarios se crean asignados a un area (AreaId obligatorio). EsSupervisor en 0 por defecto;
-- los primeros de cada unidad quedan como supervisores para el ejemplo.
INSERT INTO Usuario (SyncUsuarioId, Active, AreaId, EsSupervisor, Eliminado)
SELECT S.SyncUsuarioId, 1, A.AreaId,
       CASE WHEN S.SyncUsuarioId IN (1001, 1002, 1003) THEN 1 ELSE 0 END,
       0
FROM SyncUsuarios S
INNER JOIN Unidad UN ON UN.SyncUnidadId = ((S.SyncUsuarioId - 1) % 3) + 1
INNER JOIN Area A ON A.UnidadId = UN.UnidadId AND A.Nombre = 'Administracion'
WHERE NOT EXISTS (
    SELECT 1 FROM Usuario U WHERE U.SyncUsuarioId = S.SyncUsuarioId
);
GO

SELECT * FROM SyncUnidad;
SELECT * FROM SyncUsuarios;
SELECT * FROM Unidad;
SELECT * FROM Area;
SELECT * FROM Usuario;
GO
