USE API_SCAP_DB;
GO

-- Seed de prueba: 10 usuarios en SyncUsuarios para probar la migración a Usuario.
-- Columnas: SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni
INSERT INTO SyncUsuarios (SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
SELECT V.SyncUsuarioId, V.Usuario, V.Nombres, V.Apellidos, V.Tipo, V.Dni
FROM (VALUES
    (1001, 'jperez',   'Juan',     'Pérez',     'CO', '12345678'),
    (1002, 'mlopez',   'María',    'López',     'CO', '23456789'),
    (1003, 'cramirez', 'Carlos',   'Ramírez',   'AL', '34567890'),
    (1004, 'atorres',  'Ana',      'Torres',    'CO', '45678901'),
    (1005, 'lflores',  'Luis',     'Flores',    'AL', '56789012'),
    (1006, 'rcastro',  'Rosa',     'Castro',    'CO', '67890123'),
    (1007, 'dmendoza', 'Diego',    'Mendoza',   'AL', '78901234'),
    (1008, 'nvargas',  'Natalia',  'Vargas',    'CO', '89012345'),
    (1009, 'projas',   'Pedro',    'Rojas',     'AL', '90123456'),
    (1010, 'squiroz',  'Sofía',    'Quiroz',    'CO', '01234567')
) V(SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
WHERE NOT EXISTS (
    SELECT 1 FROM SyncUsuarios S WHERE S.SyncUsuarioId = V.SyncUsuarioId
);
GO

SELECT * FROM SyncUsuarios;
GO
