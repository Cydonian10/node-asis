/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteBiometrico]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Aplicar eliminacion logica a un dispositivo biometrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteBiometrico]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Biometrico WHERE BiometricoId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El biometrico no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Biometrico
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE BiometricoId = @ID;

        SET @State = 1;
        SET @Message = 'Biometrico eliminado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
