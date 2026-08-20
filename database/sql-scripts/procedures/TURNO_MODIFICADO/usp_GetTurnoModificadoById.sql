/*======================================================================================================
 NOMBRE: [dbo].[usp_GetTurnoModificadoById]
 OBJETIVO: Obtener una modificación activa perteneciente al turno indicado.
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetTurnoModificadoById]
    @TurnoId INT,
    @TurnoModificadoId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        TM.TurnoModificadoId AS turnoModificadoId,
        TM.TurnoId AS turnoId,
        TM.UsuarioId AS usuarioId,
        TM.Fecha AS fecha,
        TM.HoraInicio AS horaInicio,
        TM.HoraFin AS horaFin,
        TM.Motivo AS motivo
    FROM TurnoModificado TM
    INNER JOIN Turno T ON T.TurnoId = TM.TurnoId
    WHERE TM.TurnoModificadoId = @TurnoModificadoId
        AND TM.TurnoId = @TurnoId
        AND TM.Eliminado = 0
        AND T.Eliminado = 0;
END
GO
