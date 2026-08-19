/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlById]
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Obtener un control no eliminado con sus asignaciones activas de area, unidad y usuario.
          Devuelve 4 result sets: control, asignaciones de area, asignaciones de unidad y asignaciones de usuario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetControlById]
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.ControlId AS controlId,
        C.Tolerancia AS tolerancia,
        C.LimiteTardanza AS limiteTardanza,
        C.LimiteFalta AS limiteFalta
    FROM [Control] C
    WHERE C.ControlId = @ID AND C.Eliminado = 0;

    SELECT
        CA.ControlId AS controlId,
        CA.ControlAreaId AS controlAreaId,
        CA.AreaId AS areaId
    FROM ControlArea CA
    INNER JOIN [Control] C ON C.ControlId = CA.ControlId
    WHERE CA.ControlId = @ID AND CA.Eliminado = 0 AND C.Eliminado = 0
    ORDER BY CA.ControlAreaId;

    SELECT
        CUN.ControlId AS controlId,
        CUN.ControlUnidadId AS controlUnidadId,
        CUN.UnidadId AS unidadId
    FROM ControlUnidad CUN
    INNER JOIN [Control] C ON C.ControlId = CUN.ControlId
    WHERE CUN.ControlId = @ID AND CUN.Eliminado = 0 AND C.Eliminado = 0
    ORDER BY CUN.ControlUnidadId;

    SELECT
        CUS.ControlId AS controlId,
        CUS.ControlUsuarioId AS controlUsuarioId,
        CUS.UsuarioId AS usuarioId
    FROM ControlUsuario CUS
    INNER JOIN [Control] C ON C.ControlId = CUS.ControlId
    WHERE CUS.ControlId = @ID AND CUS.Eliminado = 0 AND C.Eliminado = 0
    ORDER BY CUS.ControlUsuarioId;
END
GO