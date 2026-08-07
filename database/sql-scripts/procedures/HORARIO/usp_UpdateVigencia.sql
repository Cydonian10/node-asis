/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateVigencia]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar una vigencia (ISNULL sobre la columna actual).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateVigencia]
    -- Parametros de entrada
    @ID INT,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
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

        DECLARE @NuevoInicio DATE = ISNULL(@FechaInicio, (SELECT FechaInicio FROM Vigencia WHERE VigenciaId = @ID));
        DECLARE @NuevoFin DATE = ISNULL(@FechaFin, (SELECT FechaFin FROM Vigencia WHERE VigenciaId = @ID));

        IF @NuevoFin IS NOT NULL AND @NuevoFin < @NuevoInicio
        BEGIN
            SET @State = -1;
            SET @Message = 'FechaFin no puede ser anterior a FechaInicio';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Vigencia
        SET FechaInicio = @NuevoInicio,
            FechaFin = @NuevoFin,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE VigenciaId = @ID;

        SET @State = 1;
        SET @Message = 'Vigencia actualizada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
