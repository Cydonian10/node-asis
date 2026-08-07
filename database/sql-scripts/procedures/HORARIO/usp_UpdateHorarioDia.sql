/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateHorarioDia]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar el orden de un dia dentro del horario (HorarioDia).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateHorarioDia]
    -- Parametros de entrada
    @ID INT,
    @Orden INT,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM HorarioDia WHERE HorarioDiaId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El dia del horario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE HorarioDia
        SET Orden = @Orden,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE HorarioDiaId = @ID;

        SET @State = 1;
        SET @Message = 'Dia del horario actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
