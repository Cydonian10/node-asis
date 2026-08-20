/*======================================================================================================
 NOMBRE: [dbo].[usp_GetUsuarioTurnosModificados]
 OBJETIVO: Listar las modificaciones activas de todos los turnos de un usuario en un rango.
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUsuarioTurnosModificados]
    @UsuarioId INT,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL
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
        TM.Motivo AS motivo,
        H.Nombre AS horarioNombre
    FROM TurnoModificado TM
    INNER JOIN Turno T ON T.TurnoId = TM.TurnoId AND T.Eliminado = 0
    INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
    INNER JOIN Horario H ON H.HorarioId = HD.HorarioId AND H.Eliminado = 0
    WHERE TM.UsuarioId = @UsuarioId
        AND TM.Eliminado = 0
        AND (@FechaDesde IS NULL OR TM.Fecha >= @FechaDesde)
        AND (@FechaHasta IS NULL OR TM.Fecha <= @FechaHasta)
    ORDER BY TM.Fecha, TM.TurnoModificadoId;
END
GO
