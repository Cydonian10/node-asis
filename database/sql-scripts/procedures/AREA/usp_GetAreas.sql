/*======================================================================================================
NOMBRE: [dbo].[usp_GetAreas]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Listar areas (JOIN Unidad) con filtros opcionales de unidad y busqueda. Excluye las
          areas con Eliminado = 1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetAreas]
    -- Parametros de entrada
    @unidadId INT = NULL,
    @busqueda VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        A.AreaId AS areaId,
        A.UnidadId AS unidadId,
        A.Nombre AS nombre,
        A.Descripcion AS descripcion
    FROM Area A
    INNER JOIN Unidad U ON U.UnidadId = A.UnidadId
    WHERE A.Eliminado = 0
        AND (@unidadId IS NULL OR A.UnidadId = @unidadId)
        AND (
            @busqueda IS NULL
            OR A.Nombre LIKE '%' + @busqueda + '%'
            OR A.Descripcion LIKE '%' + @busqueda + '%'
        );
END
GO
