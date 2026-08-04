/*======================================================================================================
NOMBRE: [dbo].[usp_GetCursosBasicos]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los cursos preuniversitarios disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetCursosBasicos]
  @PERIODO_LECTIVO_ID INT,
  @ETAPA_EDUCATIVA VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    id AS id,
    cCursoEducacionBasica AS cursoBasico
  FROM
    Sync_CursoSeccionBasica
  WHERE idPeriodoLectivo = @PERIODO_LECTIVO_ID AND cEtapaEducativa = @ETAPA_EDUCATIVA

END
