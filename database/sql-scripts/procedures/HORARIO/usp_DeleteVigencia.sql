/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteVigencia]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Soft-delete de una vigencia (Eliminado = 1).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteVigencia]
    -- Parametros de entrada
    @ID INT,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Vigencia WHERE VigenciaId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'La vigencia no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Vigencia
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE VigenciaId = @ID;

        SET @State = 1;
        SET @Message = 'Vigencia eliminada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
