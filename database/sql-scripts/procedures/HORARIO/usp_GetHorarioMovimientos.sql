/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioMovimientos]
FECHA: 17-08-2026
AUTOR: Gabriel
OBJETIVO: Retornar el estado de "movimientos" de un horario para validar ediciones de estructura.
          Devuelve dos resultsets:
            - TurnosBloqueados: turnos del horario que ya tienen Asistencia, TurnoModificado o
           estan ligados a un Permiso o Justificacion via TurnoId (no pueden cambiar
               sus horas, dia de salida ni eliminarse). Las licencias se validan por fechas
               del usuario, no por turno.
            - EstadoMovimientos: flags de movimientos del horario (asistencias, turnos modificados,
               permisos y justificaciones ligados a turnos del horario) y el flag
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
            FROM Permisos P
            INNER JOIN Turno T ON T.TurnoId = P.TurnoId
            INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
            WHERE HD.HorarioId = @HorarioId AND T.Eliminado = 0 AND HD.Eliminado = 0
        ) THEN 1 ELSE 0 END AS tienePermisos,
        CASE WHEN EXISTS (
            SELECT 1
            FROM Justificaciones J
            INNER JOIN Turno T ON T.TurnoId = J.TurnoId
            INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
            WHERE HD.HorarioId = @HorarioId AND T.Eliminado = 0 AND HD.Eliminado = 0
        ) THEN 1 ELSE 0 END AS tieneJustificaciones
    FROM (SELECT 1 AS dummy) AS d;
END
GO

