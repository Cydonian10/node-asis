/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteTurnoDiaConectado]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Soft-delete del dia conectado de un turno (SalidaTurnoDia Eliminado = 1).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteTurnoDiaConectado]
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
        IF NOT EXISTS (SELECT 1 FROM SalidaTurnoDia WHERE SalidaTurnoDiaId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El dia conectado no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE SalidaTurnoDia
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE SalidaTurnoDiaId = @ID;

        SET @State = 1;
        SET @Message = 'Dia conectado eliminado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
