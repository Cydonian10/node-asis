/*======================================================================================================
NOMBRE: [dbo].[usp_GetMarcaBiometricos]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Listar marcas de biometrico no eliminadas.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetMarcaBiometricos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        M.MarcaBiometricoId AS marcaBiometricoId,
        M.Nombre AS nombre,
        M.TipoDB AS tipoDB,
        M.Detalle AS detalle
    FROM MarcaBiometrico M
    WHERE M.Eliminado = 0
    ORDER BY M.Nombre;
END
GO
