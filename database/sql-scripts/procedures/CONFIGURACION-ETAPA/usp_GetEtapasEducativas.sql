/*======================================================================================================
NOMBRE: [dbo].[usp_GetEtapasEducativas]
FECHA: 01-10-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Lista de etapas educativas

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetEtapasEducativas]
  @PERIODO_LECTIVO_ID INT,
  @NIVEL_EDUCATIVO VARCHAR(50)
AS
BEGIN
  SELECT
    cEtapaEducativa as nombre
  FROM Sync_ConfiguracionEtapa
  WHERE idPeriodoLectivo = @PERIODO_LECTIVO_ID
    AND cNivelEducativo = @NIVEL_EDUCATIVO
  GROUP BY cEtapaEducativa
  ORDER BY cEtapaEducativa
END

GO
