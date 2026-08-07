/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoDiaConectado]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Retornar el/los dias conectados de un turno (JOIN SalidaTurnoDia + Turno + Dia) junto con
          el flag Extendido del turno para verificar si aplica dia conectado.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetTurnoDiaConectado]
    -- Parametros de entrada
    @TurnoId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        STD.SalidaTurnoDiaId AS salidaTurnoDiaId,
        STD.TurnoId AS turnoId,
        T.Extendido AS extendido,
        STD.DiaId AS diaId,
        D.Nombre AS diaNombre
    FROM SalidaTurnoDia STD
    INNER JOIN Turno T ON T.TurnoId = STD.TurnoId
    INNER JOIN Dia D ON D.DiaId = STD.DiaId
    WHERE STD.TurnoId = @TurnoId
        AND STD.Eliminado = 0
    ORDER BY D.Orden;
END
GO
