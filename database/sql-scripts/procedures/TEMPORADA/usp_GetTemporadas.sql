/*======================================================================================================
NOMBRE: [dbo].[usp_GetTemporadas]
FECHA: 19/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener las temporadas disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetTemporadas]
    @PERIODO_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        idTemporada AS id,
        cTemporada AS nombre
    FROM
        Sync_Temporada
    WHERE 
        idPeriodoLectivo = @PERIODO_ID
    GROUP BY 
        idTemporada, cTemporada
    ORDER BY 
        idTemporada DESC;
END



