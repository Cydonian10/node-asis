/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioDetalle]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Retornar el horario con todos sus dias (HorarioDia), turnos y vigencia anidados, listo
          para dibujar en el front. Devuelve tres resultsets: horario (1 fila), dias (con turnos y
          vigencia en una sola fila por turno con NULLs para vigencia cuando no aplica).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorarioDetalle]
    -- Parametros de entrada
    @HorarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Resultsets 1 y 2 no se usan de forma directa; se mantienen como consulta de referencia
    -- (el modulo arma el arbol en TypeScript con el recordset de la consulta 3).

    SELECT
        H.HorarioId AS horarioId,
        H.Nombre AS nombre,
        H.AreaId AS areaId,
        A.Nombre AS areaNombre,
        A.UnidadId AS unidadId,
        H.Extendido AS extendido,
        H.Rotativo AS rotativo,
        H.Regular AS regular,
        H.HorasLaborales AS horasLaborales
    FROM Horario H
    INNER JOIN Area A ON A.AreaId = H.AreaId
    WHERE H.HorarioId = @HorarioId
        AND H.Eliminado = 0;

    SELECT
        HD.HorarioDiaId AS horarioDiaId,
        HD.DiaId AS diaId,
        D.Nombre AS diaNombre,
        HD.Orden AS orden
    FROM HorarioDia HD
    INNER JOIN Dia D ON D.DiaId = HD.DiaId
    WHERE HD.HorarioId = @HorarioId
        AND HD.Eliminado = 0
    ORDER BY HD.Orden;

    SELECT
        HD.HorarioDiaId AS horarioDiaId,
        HD.DiaId AS diaId,
        D.Nombre AS diaNombre,
        HD.Orden AS orden,
        T.TurnoId AS turnoId,
        T.HoraInicio AS horaInicio,
        T.HoraFin AS horaFin,
        T.Extendido AS extendido,
        SD.DiaId AS salidaDiaId,
        SD.Nombre AS salidaDiaNombre,
        V.VigenciaId AS vigenciaId,
        V.FechaInicio AS fechaInicio,
        V.FechaFin AS fechaFin
    FROM HorarioDia HD
    INNER JOIN Dia D ON D.DiaId = HD.DiaId
    LEFT JOIN Turno T ON T.HorarioDiaId = HD.HorarioDiaId AND T.Eliminado = 0
    LEFT JOIN SalidaTurnoDia STD ON STD.TurnoId = T.TurnoId AND STD.Eliminado = 0
    LEFT JOIN Dia SD ON SD.DiaId = STD.DiaId
    LEFT JOIN Vigencia V ON V.HorarioDiaId = HD.HorarioDiaId AND V.Eliminado = 0
    WHERE HD.HorarioId = @HorarioId
        AND HD.Eliminado = 0
    ORDER BY HD.Orden;
END
GO
