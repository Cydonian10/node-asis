/*======================================================================================================
NOMBRE: [dbo].[usp_GetNivelesEducativos]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los niveles educativos disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetNivelesEducativos]
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    idNivel AS id,
    nivel AS nivelEducativo
  FROM
    Sync_CursoSeccionPreUniversitaria
  GROUP BY 
    idNivel, nivel
  ORDER BY 
    idNivel DESC;
END


