USE API_SCAP_DB;
GO

-- Seed de prueba: 10 usuarios en SyncUsuarios para probar la migración a Usuario.
-- Columnas: SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni
INSERT INTO SyncUsuarios (SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
VALUES
    (1001, 'jperez',   'Juan',     'Pérez',     'DC', '12345678'),
    (1002, 'mlopez',   'María',    'López',     'DC', '23456789'),
    (1003, 'cramirez', 'Carlos',   'Ramírez',   'AD', '34567890'),
    (1004, 'atorres',  'Ana',      'Torres',    'DC', '45678901'),
    (1005, 'lflores',  'Luis',     'Flores',    'AD', '56789012'),
    (1006, 'rcastro',  'Rosa',     'Castro',    'DC', '67890123'),
    (1007, 'dmendoza', 'Diego',    'Mendoza',   'AD', '78901234'),
    (1008, 'nvargas',  'Natalia',  'Vargas',    'DC', '89012345'),
    (1009, 'projas',   'Pedro',    'Rojas',     'AD', '90123456'),
    (1010, 'squiroz',  'Sofía',    'Quiroz',    'DC', '01234567');
GO

SELECT * FROM SyncUsuarios;
GO
