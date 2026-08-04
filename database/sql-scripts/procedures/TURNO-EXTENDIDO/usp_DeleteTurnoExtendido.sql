
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteTurnoExtendido]
FECHA: 17/10/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite la eliminación logica de turnos extendidos.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteTurnoExtendido]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar el estado del turno extendido a eliminado (por ejemplo, Estado = 0)
        UPDATE TurnoExtendido
        SET 
            bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE 
            ID = @ID;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró el turno extendido con el ID proporcionado.';
            SET @CodeError = 1;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SET @State = 1;
        SET @Message = 'Turno extendido eliminado correctamente.';
        SET @CodeError = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END