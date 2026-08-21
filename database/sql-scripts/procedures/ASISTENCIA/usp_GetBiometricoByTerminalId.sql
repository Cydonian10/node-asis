/*======================================================================================================
NOMBRE: [dbo].[usp_GetBiometricoByTerminalId]
OBJETIVO: Resolver un biometrico activo a partir del TerminalId recibido en una Marcacion.
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetBiometricoByTerminalId]
    @TerminalId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT B.BiometricoId AS biometricoId
    FROM Biometrico B
    WHERE B.TerminalId = @TerminalId
      AND B.Eliminado = 0;
END
GO
