/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlAplicable]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Obtener el Control aplicable a un usuario con jerarquia: ControlUsuario (especifico) ->
          ControlArea (de su AreaId) -> ControlUnidad (de Area.UnidadId) -> default 0.
          Devuelve ControlId, Tolerancia, LimiteFalta, LimiteTardanza (una sola fila).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetControlAplicable]
    @UsuarioId INT,
    @AreaId INT,
    @UnidadId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        C.ControlId AS controlId,
        C.Tolerancia AS tolerancia,
        C.LimiteFalta AS limiteFalta,
        C.LimiteTardanza AS limiteTardanza
    FROM (
        -- Jerarquia de precedencia: Usuario (1) > Area (2) > Unidad (3)
        SELECT CU.ControlId AS ControlId, 1 AS Precedencia
        FROM ControlUsuario CU
        WHERE CU.UsuarioId = @UsuarioId AND CU.Eliminado = 0

        UNION ALL

        SELECT CA.ControlId, 2
        FROM ControlArea CA
        WHERE CA.AreaId = @AreaId AND CA.Eliminado = 0

        UNION ALL

        SELECT CUN.ControlId, 3
        FROM ControlUnidad CUN
        WHERE CUN.UnidadId = @UnidadId AND CUN.Eliminado = 0
    ) S
    INNER JOIN [Control] C ON C.ControlId = S.ControlId AND C.Eliminado = 0
    ORDER BY S.Precedencia ASC;
END
GO
