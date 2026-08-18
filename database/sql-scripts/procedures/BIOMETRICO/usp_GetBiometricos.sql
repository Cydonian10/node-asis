/*======================================================================================================
NOMBRE: [dbo].[usp_GetBiometricos]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Listar dispositivos biometricos no eliminados con su marca.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetBiometricos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        B.BiometricoId AS biometricoId,
        B.MarcaBiometricoId AS marcaBiometricoId,
        M.Nombre AS marcaNombre,
        B.Nombre AS nombre,
        B.Ip AS ip,
        B.Serie AS serie,
        B.Ubicacion AS ubicacion,
        B.Tarjeta AS tarjeta,
        B.Huella AS huella,
        B.Rostro AS rostro
    FROM Biometrico B
    INNER JOIN MarcaBiometrico M ON M.MarcaBiometricoId = B.MarcaBiometricoId
    WHERE B.Eliminado = 0
      AND M.Eliminado = 0
    ORDER BY B.Nombre;
END
GO
