/*======================================================================================================
NOMBRE: [dbo].[usp_CreateBiometrico]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Crear un dispositivo biometrico asociado a una marca.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateBiometrico]
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
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
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

        INSERT INTO Biometrico
        (
            MarcaBiometricoId, Nombre, Ip, Serie, Ubicacion,
            Tarjeta, Huella, Rostro, CreatedBy, UpdatedBy
        )
        VALUES
        (
            @MarcaBiometricoId, @Nombre, @Ip, @Serie, @Ubicacion,
            @Tarjeta, @Huella, @Rostro, @USER, @USER
        );

        SET @Id = CONVERT(INT, SCOPE_IDENTITY());
        SET @State = 1;
        SET @Message = 'Biometrico creado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
