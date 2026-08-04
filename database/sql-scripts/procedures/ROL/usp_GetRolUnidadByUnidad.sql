/*======================================================================================================
NOMBRE: [dbo].[usp_GetRolUnidadByUnidad]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Listar los roles-en-unidad (RolUnidad JOIN Rol) de una unidad. Excluye Eliminado = 1
          tanto en RolUnidad como en Rol.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetRolUnidadByUnidad]
    -- Parametros de entrada
    @UnidadId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        RU.RolUnidadId AS rolUnidadId,
        RU.RolId AS rolId,
        RU.UnidadId AS unidadId,
        R.Nombre AS nombre,
        R.Descripcion AS descripcion
    FROM RolUnidad RU
    INNER JOIN Rol R ON R.RolId = RU.RolId
    WHERE RU.UnidadId = @UnidadId
        AND RU.Eliminado = 0
        AND R.Eliminado = 0;
END
GO
