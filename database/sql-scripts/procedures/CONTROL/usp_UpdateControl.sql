/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateControl]
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar parcialmente un control no eliminado. Solo se actualizan los valores enviados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateControl]
    @ID INT,
    @Tolerancia INT = NULL,
    @LimiteTardanza INT = NULL,
    @LimiteFalta INT = NULL,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM [Control] WHERE ControlId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El control no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF (@Tolerancia IS NOT NULL AND @Tolerancia < 0)
           OR (@LimiteTardanza IS NOT NULL AND @LimiteTardanza < 0)
           OR (@LimiteFalta IS NOT NULL AND @LimiteFalta < 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Los valores de tolerancia, limite de tardanza y limite de falta deben ser mayores o iguales a 0';
            SET @CodeError = -1;
            RETURN;
        END

        IF @Tolerancia IS NULL AND @LimiteTardanza IS NULL AND @LimiteFalta IS NULL
        BEGIN
            SET @State = -1;
            SET @Message = 'Debe enviar al menos un valor para actualizar';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE [Control]
        SET Tolerancia = COALESCE(@Tolerancia, Tolerancia),
            LimiteTardanza = COALESCE(@LimiteTardanza, LimiteTardanza),
            LimiteFalta = COALESCE(@LimiteFalta, LimiteFalta),
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE ControlId = @ID;

        SET @State = 1;
        SET @Message = 'Control actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO