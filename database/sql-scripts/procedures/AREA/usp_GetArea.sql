/*======================================================================================================
NOMBRE: [dbo].[usp_GetArea]
FECHA: 13-08-2026
AUTOR: Gabriel
OBJETIVO: Listar un area por su Id (JOIN Unidad + SyncUnidad). Excluye areas con Eliminado = 1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetArea]
    -- Parametros de entrada
    @areaId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        A.AreaId AS areaId,
        A.UnidadId AS unidadId,
        SU.Nombre AS unidadNombre,
        A.Nombre AS nombre,
        A.Descripcion AS descripcion
    FROM Area A
    INNER JOIN Unidad U ON U.UnidadId = A.UnidadId
    INNER JOIN SyncUnidad SU ON SU.SyncUnidadId = U.SyncUnidadId
    WHERE A.AreaId = @areaId AND A.Eliminado = 0;
END
GO
