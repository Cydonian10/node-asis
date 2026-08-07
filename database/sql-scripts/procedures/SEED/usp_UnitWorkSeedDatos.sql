/*======================================================================================================
NOMBRE: [dbo].[usp_UnitWorkSeedDatos]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Sembrar datos de prueba para el modulo seed. Crea 3 unidades (Colegio, Academia,
          Pre-Academia), 3 usuarios con horario (uno con turno extendido, uno sin turnos extendidos,
          uno con permiso), vigencias de horario de hoy a fin de anio (solo unidad Colegio) y
          justificaciones. Re-ejecutable: primero limpia el seed anterior y luego inserta.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnitWorkSeedDatos]
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ===================== LIMPIEZA PREVIA DEL SEED =====================
        -- Asistencias y marcaciones de usuarios seed (el motor de asistencia pudo crearlas)
        DELETE AM FROM AsistenciaMarcacion AM
        INNER JOIN Asistencia A ON A.AsistenciaId = AM.AsistenciaId
        INNER JOIN Usuario U ON U.UsuarioId = A.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE A FROM Asistencia A
        INNER JOIN Usuario U ON U.UsuarioId = A.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE TM FROM TurnoModificado TM
        INNER JOIN Usuario U ON U.UsuarioId = TM.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE V FROM Vacaciones V
        INNER JOIN Usuario U ON U.UsuarioId = V.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE DV FROM DetalleVacaciones DV
        INNER JOIN Vacaciones V ON V.VacacionId = DV.VacacionId
        INNER JOIN Usuario U ON U.UsuarioId = V.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE L FROM Licencia L
        INNER JOIN Usuario U ON U.UsuarioId = L.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE C FROM Cita C
        INNER JOIN Usuario U ON U.UsuarioId = C.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE CU FROM ControlUsuario CU
        INNER JOIN Usuario U ON U.UsuarioId = CU.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE STD FROM SalidaTurnoDia STD
        INNER JOIN Turno T ON T.TurnoId = STD.TurnoId
        INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
        INNER JOIN Horario H ON H.HorarioId = HD.HorarioId
        WHERE H.Nombre LIKE 'Seed %';

        DELETE TM2 FROM TurnoModificado TM2
        INNER JOIN Turno T2 ON T2.TurnoId = TM2.TurnoId
        INNER JOIN HorarioDia HD2 ON HD2.HorarioDiaId = T2.HorarioDiaId
        INNER JOIN Horario H2 ON H2.HorarioId = HD2.HorarioId
        WHERE H2.Nombre LIKE 'Seed %';

        DELETE T FROM Turno T
        INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
        INNER JOIN Horario H ON H.HorarioId = HD.HorarioId
        WHERE H.Nombre LIKE 'Seed %';

        DELETE V FROM Vigencia V
        INNER JOIN HorarioDia HD ON HD.HorarioDiaId = V.HorarioDiaId
        INNER JOIN Horario H ON H.HorarioId = HD.HorarioId
        WHERE H.Nombre LIKE 'Seed %';

        DELETE HD FROM HorarioDia HD
        INNER JOIN Horario H ON H.HorarioId = HD.HorarioId
        WHERE H.Nombre LIKE 'Seed %';

        DELETE HA FROM HorarioAsignacion HA
        INNER JOIN Horario H ON H.HorarioId = HA.HorarioId
        WHERE H.Nombre LIKE 'Seed %';

        DELETE H FROM Horario H WHERE H.Nombre LIKE 'Seed %';

        DELETE P FROM Permisos P
        INNER JOIN Usuario U ON U.UsuarioId = P.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE J FROM Justificaciones J
        INNER JOIN Usuario U ON U.UsuarioId = J.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE U FROM Usuario U WHERE U.SyncUsuarioId IN (2001, 2002, 2003);
        DELETE S FROM SyncUsuarios S WHERE S.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE CA FROM ControlArea CA
        INNER JOIN Area A ON A.AreaId = CA.AreaId
        INNER JOIN Unidad UN ON UN.UnidadId = A.UnidadId
        WHERE UN.SyncUnidadId IN (10, 11, 12);

        DELETE FU FROM FeriadoUnidad FU
        INNER JOIN Unidad UN ON UN.UnidadId = FU.UnidadId
        WHERE UN.SyncUnidadId IN (10, 11, 12);

        DELETE CUN FROM ControlUnidad CUN
        INNER JOIN Unidad UN ON UN.UnidadId = CUN.UnidadId
        WHERE UN.SyncUnidadId IN (10, 11, 12);

        DELETE A FROM Area A
        INNER JOIN Unidad UN ON UN.UnidadId = A.UnidadId
        WHERE UN.SyncUnidadId IN (10, 11, 12);

        DELETE UN FROM Unidad UN WHERE UN.SyncUnidadId IN (10, 11, 12);
        DELETE SU FROM SyncUnidad SU WHERE SU.SyncUnidadId IN (10, 11, 12);

        -- ===================== UNIDADES =====================
        INSERT INTO SyncUnidad (SyncUnidadId, Codigo, Nombre)
        VALUES (10, 'COL', 'Colegio'),
               (11, 'PRE', 'Pre-Academia'),
               (12, 'ACA', 'Academia');

        INSERT INTO Unidad (SyncUnidadId, HorasLaborales, HorasLaboralesTotales)
        SELECT SyncUnidadId, 8, 40 FROM SyncUnidad WHERE SyncUnidadId IN (10, 11, 12);

        DECLARE @AreaColegio INT, @AreaAcademia INT, @AreaPre INT;

        INSERT INTO Area (UnidadId, Nombre, Descripcion, CreatedBy, UpdatedBy)
        VALUES ((SELECT UnidadId FROM Unidad WHERE SyncUnidadId = 10), 'Administracion', 'Area seed Colegio', @USER, @USER);
        SET @AreaColegio = SCOPE_IDENTITY();

        INSERT INTO Area (UnidadId, Nombre, Descripcion, CreatedBy, UpdatedBy)
        VALUES ((SELECT UnidadId FROM Unidad WHERE SyncUnidadId = 12), 'Administracion', 'Area seed Academia', @USER, @USER);
        SET @AreaAcademia = SCOPE_IDENTITY();

        INSERT INTO Area (UnidadId, Nombre, Descripcion, CreatedBy, UpdatedBy)
        VALUES ((SELECT UnidadId FROM Unidad WHERE SyncUnidadId = 11), 'Administracion', 'Area seed Pre-Academia', @USER, @USER);
        SET @AreaPre = SCOPE_IDENTITY();

        -- ===================== USUARIOS =====================
        INSERT INTO SyncUsuarios (SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
        VALUES (2001, 'jperez', 'Juan', 'Perez', 'CO', '20010001'),
               (2002, 'mlopez', 'Maria', 'Lopez', 'CO', '20020002'),
               (2003, 'cramirez', 'Carlos', 'Ramirez', 'AL', '20030003');

        INSERT INTO Usuario (SyncUsuarioId, Active, AreaId, EsSupervisor, Eliminado)
        VALUES (2001, 1, @AreaColegio, 0, 0),
               (2002, 1, @AreaColegio, 0, 0),
               (2003, 1, @AreaAcademia, 0, 0);

        -- ===================== HORARIOS =====================
        -- Horario 1: Colegio, regular, CON turno extendido (Viernes cruza medianoche)
        INSERT INTO Horario (Nombre, Extendido, Rotativo, Regular, AreaId, HorasLaborales, Eliminado, CreatedBy, UpdatedBy)
        VALUES ('Seed Horario Colegio Extendido', 1, 0, 1, @AreaColegio, 8, 0, @USER, @USER);
        DECLARE @HorarioExt INT = SCOPE_IDENTITY();

        -- Horario 2: Colegio, regular, SIN turnos extendidos
        INSERT INTO Horario (Nombre, Extendido, Rotativo, Regular, AreaId, HorasLaborales, Eliminado, CreatedBy, UpdatedBy)
        VALUES ('Seed Horario Colegio Regular', 0, 0, 1, @AreaColegio, 8, 0, @USER, @USER);
        DECLARE @HorarioReg INT = SCOPE_IDENTITY();

        -- Horario 3: Academia, regular, para el usuario con permiso
        INSERT INTO Horario (Nombre, Extendido, Rotativo, Regular, AreaId, HorasLaborales, Eliminado, CreatedBy, UpdatedBy)
        VALUES ('Seed Horario Academia Permiso', 0, 0, 1, @AreaAcademia, 8, 0, @USER, @USER);
        DECLARE @HorarioPerm INT = SCOPE_IDENTITY();

        -- Dias del horario extendido: Lunes a Viernes (DiaId 1..5)
        INSERT INTO HorarioDia (HorarioId, DiaId, Orden, Eliminado, CreatedBy, UpdatedBy)
        SELECT @HorarioExt, DiaId, DiaId, 0, @USER, @USER
        FROM Dia WHERE DiaId BETWEEN 1 AND 5;

        -- Turnos del horario extendido: Lunes-Jueves 08:00-16:00; Viernes 08:00-02:00 (extendido)
        INSERT INTO Turno (HorarioDiaId, HoraInicio, HoraFin, Extendido, Eliminado, CreatedBy, UpdatedBy)
        SELECT HD.HorarioDiaId,
               CASE WHEN HD.DiaId = 5 THEN CAST('08:00' AS TIME) ELSE CAST('08:00' AS TIME) END,
               CASE WHEN HD.DiaId = 5 THEN CAST('02:00' AS TIME) ELSE CAST('16:00' AS TIME) END,
               CASE WHEN HD.DiaId = 5 THEN 1 ELSE 0 END,
               0, @USER, @USER
        FROM HorarioDia HD WHERE HD.HorarioId = @HorarioExt;

        -- Dia conectado del turno extendido (Viernes sale el Sabado)
        INSERT INTO SalidaTurnoDia (TurnoId, DiaId, Eliminado, CreatedBy, UpdatedBy)
        SELECT T.TurnoId, 6, 0, @USER, @USER
        FROM Turno T
        INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
        WHERE HD.HorarioId = @HorarioExt AND T.Extendido = 1;

        -- Dias del horario regular (Colegio) y del horario de Academia
        INSERT INTO HorarioDia (HorarioId, DiaId, Orden, Eliminado, CreatedBy, UpdatedBy)
        SELECT @HorarioReg, DiaId, DiaId, 0, @USER, @USER
        FROM Dia WHERE DiaId BETWEEN 1 AND 5;

        INSERT INTO HorarioDia (HorarioId, DiaId, Orden, Eliminado, CreatedBy, UpdatedBy)
        SELECT @HorarioPerm, DiaId, DiaId, 0, @USER, @USER
        FROM Dia WHERE DiaId BETWEEN 1 AND 5;

        INSERT INTO Turno (HorarioDiaId, HoraInicio, HoraFin, Extendido, Eliminado, CreatedBy, UpdatedBy)
        SELECT HD.HorarioDiaId, CAST('09:00' AS TIME), CAST('17:00' AS TIME), 0, 0, @USER, @USER
        FROM HorarioDia HD WHERE HD.HorarioId = @HorarioReg;

        INSERT INTO Turno (HorarioDiaId, HoraInicio, HoraFin, Extendido, Eliminado, CreatedBy, UpdatedBy)
        SELECT HD.HorarioDiaId, CAST('07:00' AS TIME), CAST('15:00' AS TIME), 0, 0, @USER, @USER
        FROM HorarioDia HD WHERE HD.HorarioId = @HorarioPerm;

        -- ===================== VIGENCIA (solo unidad Colegio) =====================
        -- De hoy a fin de anio sobre los HorarioDia de los horarios de Colegio
        INSERT INTO Vigencia (HorarioDiaId, FechaInicio, FechaFin, Eliminado, CreatedBy, UpdatedBy)
        SELECT HD.HorarioDiaId, CAST(GETDATE() AS DATE), DATEFROMPARTS(YEAR(GETDATE()), 12, 31), 0, @USER, @USER
        FROM HorarioDia HD
        WHERE HD.HorarioId IN (@HorarioExt, @HorarioReg);

        -- ===================== ASIGNACION DE USUARIOS =====================
        INSERT INTO HorarioAsignacion (UsuarioId, HorarioId, FechaInicio, FechaFin, Eliminado, CreatedBy, UpdatedBy)
        SELECT U.UsuarioId, @HorarioExt, CAST(GETDATE() AS DATE), NULL, 0, @USER, @USER
        FROM Usuario U WHERE U.SyncUsuarioId = 2001;

        INSERT INTO HorarioAsignacion (UsuarioId, HorarioId, FechaInicio, FechaFin, Eliminado, CreatedBy, UpdatedBy)
        SELECT U.UsuarioId, @HorarioReg, CAST(GETDATE() AS DATE), NULL, 0, @USER, @USER
        FROM Usuario U WHERE U.SyncUsuarioId = 2002;

        INSERT INTO HorarioAsignacion (UsuarioId, HorarioId, FechaInicio, FechaFin, Eliminado, CreatedBy, UpdatedBy)
        SELECT U.UsuarioId, @HorarioPerm, CAST(GETDATE() AS DATE), NULL, 0, @USER, @USER
        FROM Usuario U WHERE U.SyncUsuarioId = 2003;

        -- ===================== PERMISO (usuario 2003) =====================
        INSERT INTO Permisos (UsuarioId, FechaSolicitud, HoraSalida, HoraRetorno, Motivo, HoraDeRetornoEstimada, Tipo, Estado, CreatedBy, UpdatedBy)
        SELECT U.UsuarioId, GETDATE(), '12:00', '14:00', 'Permiso seed', '14:00', 'Personal', 'Aprobado', @USER, @USER
        FROM Usuario U WHERE U.SyncUsuarioId = 2003;

        -- ===================== JUSTIFICACIONES =====================
        INSERT INTO Justificaciones (UsuarioId, Fecha, Motivo, Archivo, CreatedBy, UpdatedBy)
        SELECT U.UsuarioId, CAST(GETDATE() AS DATE), 'Justificacion seed 2001', NULL, @USER, @USER
        FROM Usuario U WHERE U.SyncUsuarioId = 2001;

        INSERT INTO Justificaciones (UsuarioId, Fecha, Motivo, Archivo, CreatedBy, UpdatedBy)
        SELECT U.UsuarioId, CAST(GETDATE() AS DATE), 'Justificacion seed 2002', NULL, @USER, @USER
        FROM Usuario U WHERE U.SyncUsuarioId = 2002;

        COMMIT TRANSACTION;

        SET @Id = (SELECT TOP 1 UnidadId FROM Unidad WHERE SyncUnidadId = 10);
        SET @State = 1;
        SET @Message = 'Seed de datos creado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
