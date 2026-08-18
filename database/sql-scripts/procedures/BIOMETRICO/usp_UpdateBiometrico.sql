/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateBiometrico]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar todos los datos de un dispositivo biometrico no eliminado.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateBiometrico]
    @ID INT,
    @MarcaBiometricoId INT,
    @Nombre VARCHAR(40),
    @Ip VARCHAR(20),
    @Serie VARCHAR(20),
    @Ubicacion VARCHAR(50),
    @Tarjeta BIT,
    @Huella BIT,
    @Rostro BIT,
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

        IF NOT EXISTS (
            SELECT 1
            FROM MarcaBiometrico
            WHERE MarcaBiometricoId = @MarcaBiometricoId
              AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'La marca de biometrico no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Biometrico
        SET MarcaBiometricoId = @MarcaBiometricoId,
            Nombre = @Nombre,
            Ip = @Ip,
            Serie = @Serie,
            Ubicacion = @Ubicacion,
            Tarjeta = @Tarjeta,
            Huella = @Huella,
            Rostro = @Rostro,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE BiometricoId = @ID;

        SET @State = 1;
        SET @Message = 'Biometrico actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
