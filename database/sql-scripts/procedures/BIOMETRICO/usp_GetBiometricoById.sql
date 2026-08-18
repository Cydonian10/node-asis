/*======================================================================================================
NOMBRE: [dbo].[usp_GetBiometricoById]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Obtener un dispositivo biometrico no eliminado por identificador.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetBiometricoById]
    @ID INT
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
    WHERE B.BiometricoId = @ID
      AND B.Eliminado = 0
      AND M.Eliminado = 0;
END
GO
