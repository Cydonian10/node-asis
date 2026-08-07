/*======================================================================================================
NOMBRE: [dbo].[usp_UnitWorkDeleteSeedDatos]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Eliminar todo el seed creado por usp_UnitWorkSeedDatos: unidades (Colegio, Academia,
          Pre-Academia), sus areas, usuarios, horarios, turnos, vigencias, asignaciones, permisos y
          justificaciones. Re-ejecutable (no falla si no hay datos).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnitWorkDeleteSeedDatos]
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

        -- ===================== LIMPIEZA DE USUARIOS SEED (2001-2003) =====================
        -- Asistencias y sus marcaciones (el motor de asistencia pudo crearlas)
        DELETE AM FROM AsistenciaMarcacion AM
        INNER JOIN Asistencia A ON A.AsistenciaId = AM.AsistenciaId
        INNER JOIN Usuario U ON U.UsuarioId = A.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE A FROM Asistencia A
        INNER JOIN Usuario U ON U.UsuarioId = A.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        -- Otros registros que referencian a los usuarios seed
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

        -- Permisos / Justificaciones de usuarios seed
        DELETE P FROM Permisos P
        INNER JOIN Usuario U ON U.UsuarioId = P.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        DELETE J FROM Justificaciones J
        INNER JOIN Usuario U ON U.UsuarioId = J.UsuarioId
        WHERE U.SyncUsuarioId IN (2001, 2002, 2003);

        -- Horarios (nombres 'Seed %')
        DELETE HA FROM HorarioAsignacion HA
        INNER JOIN Horario H ON H.HorarioId = HA.HorarioId
        WHERE H.Nombre LIKE 'Seed %';

        DELETE STD FROM SalidaTurnoDia STD
        INNER JOIN Turno T ON T.TurnoId = STD.TurnoId
        INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
        INNER JOIN Horario H ON H.HorarioId = HD.HorarioId
        WHERE H.Nombre LIKE 'Seed %';

        DELETE TM FROM TurnoModificado TM
        INNER JOIN Turno T ON T.TurnoId = TM.TurnoId
        INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
        INNER JOIN Horario H ON H.HorarioId = HD.HorarioId
        WHERE H.Nombre LIKE 'Seed %';

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

        DELETE H FROM Horario H WHERE H.Nombre LIKE 'Seed %';

        -- Usuarios seed
        DELETE U FROM Usuario U WHERE U.SyncUsuarioId IN (2001, 2002, 2003);
        DELETE S FROM SyncUsuarios S WHERE S.SyncUsuarioId IN (2001, 2002, 2003);

        -- Areas / controles / feriados de unidades seed
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

        -- Unidades seed
        DELETE UN FROM Unidad UN WHERE UN.SyncUnidadId IN (10, 11, 12);
        DELETE SU FROM SyncUnidad SU WHERE SU.SyncUnidadId IN (10, 11, 12);

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Seed de datos eliminado correctamente';
        SET @Id = 0;
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
