/*======================================================================================================
NOMBRE: [dbo].[usp_GetUnidades]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Listar unidades migradas (JOIN SyncUnidad + Unidad) con filtro opcional de busqueda.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUnidades]
    -- Parametros de entrada
    @busqueda VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.UnidadId AS unidadId,
        SU.SyncUnidadId AS syncUnidadId,
        SU.Codigo AS codigo,
        SU.Nombre AS nombre,
        U.HorasLaborales AS horasLaborales,
        U.HorasLaboralesTotales AS horasLaboralesTotales
    FROM Unidad U
    INNER JOIN SyncUnidad SU ON SU.SyncUnidadId = U.SyncUnidadId
    WHERE (
            @busqueda IS NULL
            OR SU.Codigo LIKE '%' + @busqueda + '%'
            OR SU.Nombre LIKE '%' + @busqueda + '%'
        );
END
GO
