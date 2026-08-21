/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteMotivo]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Eliminar un motivo.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -    -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteMotivo]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Motivo WHERE MotivoId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El motivo no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Motivo
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE MotivoId = @ID
          AND Eliminado = 0;

        SET @State = 1;
        SET @Message = 'Motivo eliminado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
