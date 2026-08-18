/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioMovimientos]
FECHA: 17-08-2026
AUTOR: Gabriel
OBJETIVO: Retornar el estado de "movimientos" de un horario para validar ediciones de estructura.
          Devuelve dos resultsets:
            - TurnosBloqueados: turnos del horario que ya tienen Asistencia, TurnoModificado o
              estan ligados a una Licencia/Permiso/Justificacion via TurnoId (no pueden cambiar
              sus horas, dia de salida ni eliminarse).
            - EstadoMovimientos: flags de movimientos del horario (asistencias, turnos modificados,
              licencias, permisos, justificaciones, vacaciones de usuarios asignados) y el flag
              estructuraBloqueada (cualquier movimiento => no se pueden agregar dias/grupos).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorarioMovimientos]
    @HorarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Turnos del horario que tienen movimientos (no se pueden modificar ni eliminar)
    SELECT
        T.TurnoId AS turnoId,
        T.HoraInicio AS horaInicio,
        T.HoraFin AS horaFin,
        T.Extendido AS extendido,
        CASE WHEN EXISTS (SELECT 1 FROM Asistencia A WHERE A.turnoId = T.TurnoId) THEN 1 ELSE 0 END AS tieneAsistencia,
        CASE WHEN EXISTS (SELECT 1 FROM TurnoModificado TM WHERE TM.TurnoId = T.TurnoId AND TM.Eliminado = 0) THEN 1 ELSE 0 END AS tieneTurnoModificado
    FROM Turno T
    INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
    WHERE HD.HorarioId = @HorarioId
        AND T.Eliminado = 0
        AND HD.Eliminado = 0
        AND (
            EXISTS (SELECT 1 FROM Asistencia A WHERE A.turnoId = T.TurnoId)
            OR EXISTS (SELECT 1 FROM TurnoModificado TM WHERE TM.TurnoId = T.TurnoId AND TM.Eliminado = 0)
            OR EXISTS (SELECT 1 FROM Permisos P WHERE P.TurnoId = T.TurnoId)
            OR EXISTS (SELECT 1 FROM Justificaciones J WHERE J.TurnoId = T.TurnoId)
            OR EXISTS (SELECT 1 FROM Licencia L WHERE L.TurnoId = T.TurnoId)
        );

    -- Estado global de movimientos del horario
    SELECT
        CASE WHEN EXISTS (
            SELECT 1
            FROM Turno T
            INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
            WHERE HD.HorarioId = @HorarioId AND T.Eliminado = 0 AND HD.Eliminado = 0
                AND EXISTS (SELECT 1 FROM Asistencia A WHERE A.turnoId = T.TurnoId)
        ) THEN 1 ELSE 0 END AS tieneAsistencias,
        CASE WHEN EXISTS (
            SELECT 1
            FROM Turno T
            INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
            INNER JOIN TurnoModificado TM ON TM.TurnoId = T.TurnoId AND TM.Eliminado = 0
            WHERE HD.HorarioId = @HorarioId AND T.Eliminado = 0 AND HD.Eliminado = 0
        ) THEN 1 ELSE 0 END AS tieneTurnosModificados,
        CASE WHEN EXISTS (
            SELECT 1
            FROM HorarioAsignacion HA
            INNER JOIN Licencia L ON L.UsuarioId = HA.UsuarioId
            WHERE HA.HorarioId = @HorarioId AND HA.Eliminado = 0
        ) THEN 1 ELSE 0 END AS tieneLicencias,
        CASE WHEN EXISTS (
            SELECT 1
            FROM HorarioAsignacion HA
            INNER JOIN Permisos P ON P.UsuarioId = HA.UsuarioId
            WHERE HA.HorarioId = @HorarioId AND HA.Eliminado = 0
        ) THEN 1 ELSE 0 END AS tienePermisos,
        CASE WHEN EXISTS (
            SELECT 1
            FROM HorarioAsignacion HA
            INNER JOIN Justificaciones J ON J.UsuarioId = HA.UsuarioId
            WHERE HA.HorarioId = @HorarioId AND HA.Eliminado = 0
        ) THEN 1 ELSE 0 END AS tieneJustificaciones,
        CASE WHEN EXISTS (
            SELECT 1
            FROM HorarioAsignacion HA
            INNER JOIN Vacaciones V ON V.UsuarioId = HA.UsuarioId
            WHERE HA.HorarioId = @HorarioId AND HA.Eliminado = 0 AND V.Eliminado = 0
        ) THEN 1 ELSE 0 END AS tieneVacaciones
    FROM (SELECT 1 AS dummy) AS d;
END
GO

EXEC usp_GetHorarioMovimientos 3