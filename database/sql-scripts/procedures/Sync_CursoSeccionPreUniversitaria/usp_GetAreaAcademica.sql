/*======================================================================================================
NOMBRE: [dbo].[usp_GetAreasAcademicas]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener las áreas académicas disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetAreasAcademicas]
  @TEMPORADA_ID INT,
  @NIVEL_ID INT,
  @CENTRO_ESTUDIOS_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    idAreaAcademica AS id,
    areaAcademica AS areaAcademica
  FROM
    Sync_CursoSeccionPreUniversitaria
  WHERE 
    idTemporada = @TEMPORADA_ID
    AND idNivel = @NIVEL_ID
    AND idCentroEstudios = @CENTRO_ESTUDIOS_ID
  GROUP BY 
    idAreaAcademica, areaAcademica
  ORDER BY 
    areaAcademica ASC;
END

  
