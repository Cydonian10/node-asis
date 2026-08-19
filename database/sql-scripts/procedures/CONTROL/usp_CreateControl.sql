/*======================================================================================================
NOMBRE: [dbo].[usp_CreateControl]
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Crear un control con tolerancia, limite de tardanza y limite de falta.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateControl]
    @Tolerancia INT,
    @LimiteTardanza INT,
    @LimiteFalta INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF @Tolerancia < 0 OR @LimiteTardanza < 0 OR @LimiteFalta < 0
        BEGIN
            SET @State = -1;
            SET @Message = 'Los valores de tolerancia, limite de tardanza y limite de falta deben ser mayores o iguales a 0';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO [Control] (Tolerancia, LimiteTardanza, LimiteFalta, CreatedBy, UpdatedBy)
        VALUES (@Tolerancia, @LimiteTardanza, @LimiteFalta, @USER, @USER);

        SET @Id = CONVERT(INT, SCOPE_IDENTITY());
        SET @State = 1;
        SET @Message = 'Control creado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO