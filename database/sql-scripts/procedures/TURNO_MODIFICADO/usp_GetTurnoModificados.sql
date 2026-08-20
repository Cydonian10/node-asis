/*======================================================================================================
 NOMBRE: [dbo].[usp_GetTurnoModificados]
 OBJETIVO: Listar las modificaciones activas de un turno con filtros opcionales.
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetTurnoModificados]
    @TurnoId INT,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL,
    @UsuarioId INT = NULL
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
    WHERE TM.TurnoId = @TurnoId
        AND TM.Eliminado = 0
        AND T.Eliminado = 0
        AND (@FechaDesde IS NULL OR TM.Fecha >= @FechaDesde)
        AND (@FechaHasta IS NULL OR TM.Fecha <= @FechaHasta)
        AND (@UsuarioId IS NULL OR TM.UsuarioId = @UsuarioId)
    ORDER BY TM.Fecha, TM.TurnoModificadoId;
END
GO
