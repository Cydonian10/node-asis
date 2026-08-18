/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateMarcaBiometrico]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar todos los datos de una marca de biometrico no eliminada.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateMarcaBiometrico]
    @ID INT,
    @Nombre VARCHAR(30),
    @TipoDB VARCHAR(20),
    @Detalle VARCHAR(50),
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

        IF EXISTS (
            SELECT 1
            FROM MarcaBiometrico
            WHERE Nombre = @Nombre
              AND MarcaBiometricoId <> @ID
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una marca de biometrico con ese nombre';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE MarcaBiometrico
        SET Nombre = @Nombre,
            TipoDB = @TipoDB,
            Detalle = @Detalle,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE MarcaBiometricoId = @ID;

        SET @State = 1;
        SET @Message = 'Marca de biometrico actualizada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
