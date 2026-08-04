/*======================================================================================================
NOMBRE: [dbo].[usp_GetPeriodos]
FECHA: 19/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los periodos lectivos disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetPeriodos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        idPeriodoLectivo AS id,
        cPeriodoLectivo AS nombre
    FROM
        Sync_Temporada
    GROUP BY 
        idPeriodoLectivo, cPeriodoLectivo
    ORDER BY 
        idPeriodoLectivo DESC;
END


