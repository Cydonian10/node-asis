/*======================================================================================================
NOMBRE: [dbo].[usp_GetMarcaBiometricoById]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Obtener una marca de biometrico no eliminada por identificador.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetMarcaBiometricoById]
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        M.MarcaBiometricoId AS marcaBiometricoId,
        M.Nombre AS nombre,
        M.TipoDB AS tipoDB,
        M.Detalle AS detalle
    FROM MarcaBiometrico M
    WHERE M.MarcaBiometricoId = @ID
      AND M.Eliminado = 0;
END
GO
