/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateTurno]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar un turno (ISNULL sobre la columna actual). Solo actualiza las columnas enviadas.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateTurno]
    -- Parametros de entrada
    @ID INT,
    @HoraInicio TIME = NULL,
    @HoraFin TIME = NULL,
    @Extendido BIT = NULL,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Turno WHERE TurnoId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Turno
        SET HoraInicio = ISNULL(@HoraInicio, HoraInicio),
            HoraFin = ISNULL(@HoraFin, HoraFin),
            Extendido = ISNULL(@Extendido, Extendido),
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE TurnoId = @ID;

        SET @State = 1;
        SET @Message = 'Turno actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
