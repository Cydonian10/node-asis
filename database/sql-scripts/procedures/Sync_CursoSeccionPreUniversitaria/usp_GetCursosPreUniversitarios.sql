/*======================================================================================================
NOMBRE: [dbo].[usp_GetCursosPreUniversitarios]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los cursos preuniversitarios disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetCursosPreUniversitarios]
  @TEMPORADA_ID INT,
  @NIVEL_ID INT,
  @CENTRO_ESTUDIOS_ID INT,
  @AREA_ACADEMICA_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    id as id,
    cursoPreUniversitario AS cursoPreUniversitario,
    idCursoPreUniversitario AS idCursoPreUniversitario
  FROM
    Sync_CursoSeccionPreUniversitaria

  WHERE 
    idNivel = @NIVEL_ID
    AND idTemporada = @TEMPORADA_ID
    AND idCentroEstudios = @CENTRO_ESTUDIOS_ID
    AND idAreaAcademica = @AREA_ACADEMICA_ID
  GROUP BY 
    idCursoPreUniversitario, cursoPreUniversitario, id

END


