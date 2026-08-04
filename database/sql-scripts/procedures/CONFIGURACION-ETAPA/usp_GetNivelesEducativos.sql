/*======================================================================================================
NOMBRE: [dbo].[usp_GetNivelesEducativosEscolar]
FECHA: 01-10-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Lista de niveles educativos

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetNivelesEducativosEscolar]
  @PERIODO_LECTIVO_ID INT
AS
BEGIN
  SELECT
    cNivelEducativo as nombre
  FROM Sync_ConfiguracionEtapa
  WHERE idPeriodoLectivo = @PERIODO_LECTIVO_ID
  GROUP BY cNivelEducativo
  ORDER BY cNivelEducativo
END

GO

