/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteHorarioDia]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Soft-delete en cascada de un HorarioDia: marca Eliminado = 1 en el HorarioDia y en sus
          Turnos y Vigencias asociados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteHorarioDia]
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
        IF NOT EXISTS (SELECT 1 FROM HorarioDia WHERE HorarioDiaId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El dia del horario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE T
        SET T.Eliminado = 1, T.UpdatedAt = GETDATE(), T.UpdatedBy = @USER
        FROM Turno T
        WHERE T.HorarioDiaId = @ID AND T.Eliminado = 0;

        UPDATE V
        SET V.Eliminado = 1, V.UpdatedAt = GETDATE(), V.UpdatedBy = @USER
        FROM Vigencia V
        WHERE V.HorarioDiaId = @ID AND V.Eliminado = 0;

        UPDATE HorarioDia
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE HorarioDiaId = @ID;

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Dia del horario eliminado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
