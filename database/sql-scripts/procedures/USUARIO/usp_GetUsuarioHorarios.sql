/*======================================================================================================
NOMBRE: [dbo].[usp_GetUsuarioHorarios]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Listar las asignaciones de horario de un usuario migrado con la info del horario y del
          area. El estado (activo/vencido/culminado) se calcula en Node con Culminacion y FechaFin.
          Excluye Eliminado = 1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -    -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUsuarioHorarios]
    -- Parametros de entrada
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        HA.HorarioAsignacionId AS horarioAsignacionId,
        HA.HorarioId AS horarioId,
        H.Nombre AS horarioNombre,
        H.AreaId AS areaId,
        A.Nombre AS areaNombre,
        HA.FechaInicio AS fechaInicio,
        HA.FechaFin AS fechaFin,
        HA.Culminacion AS culminacion
    FROM HorarioAsignacion HA
    INNER JOIN Horario H ON H.HorarioId = HA.HorarioId AND H.Eliminado = 0
    INNER JOIN Area A ON A.AreaId = H.AreaId AND A.Eliminado = 0
    WHERE HA.UsuarioId = @UsuarioId
        AND HA.Eliminado = 0
    ORDER BY HA.FechaInicio DESC;
END
GO
