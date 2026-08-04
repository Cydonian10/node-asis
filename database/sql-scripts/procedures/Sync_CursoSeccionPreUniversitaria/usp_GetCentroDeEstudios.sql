/*======================================================================================================
NOMBRE: [dbo].[usp_GetCentroDeEstudios]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los centros de estudios disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetCentroDeEstudios]
  @TEMPORADA_ID INT,
  @NIVEL_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    idCentroEstudios AS id,
    centroEstudios AS centroEstudios
  FROM
    Sync_CursoSeccionPreUniversitaria
  WHERE idNivel = @NIVEL_ID
    AND idTemporada = @TEMPORADA_ID
  GROUP BY 
    idCentroEstudios, centroEstudios
  ORDER BY 
    idCentroEstudios DESC;
END

