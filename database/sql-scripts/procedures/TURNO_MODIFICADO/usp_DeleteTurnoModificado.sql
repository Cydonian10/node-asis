/*======================================================================================================
 NOMBRE: [dbo].[usp_DeleteTurnoModificado]
 OBJETIVO: Eliminar lógicamente una modificación activa perteneciente a un turno.
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteTurnoModificado]
    @TurnoId INT,
    @TurnoModificadoId INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM TurnoModificado
            WHERE TurnoModificadoId = @TurnoModificadoId
                AND TurnoId = @TurnoId
                AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'La modificación de turno no existe o no pertenece al turno indicado';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM Asistencia
            WHERE TurnoId = @TurnoId
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar la modificación porque el turno tiene asistencias asociadas';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE TurnoModificado
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE TurnoModificadoId = @TurnoModificadoId
            AND TurnoId = @TurnoId
            AND Eliminado = 0;

        SET @State = 1;
        SET @Message = 'Modificación de turno eliminada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
