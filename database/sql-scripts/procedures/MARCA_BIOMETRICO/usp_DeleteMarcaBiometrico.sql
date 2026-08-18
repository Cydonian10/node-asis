/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteMarcaBiometrico]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Aplicar eliminacion logica a una marca de biometrico sin biometrico asociado.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteMarcaBiometrico]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM MarcaBiometrico WHERE MarcaBiometricoId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'La marca de biometrico no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Biometrico WHERE MarcaBiometricoId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar la marca porque tiene biometricos asociados';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE MarcaBiometrico
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE MarcaBiometricoId = @ID;

        SET @State = 1;
        SET @Message = 'Marca de biometrico eliminada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
