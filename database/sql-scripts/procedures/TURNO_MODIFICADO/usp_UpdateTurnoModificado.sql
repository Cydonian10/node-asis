/*======================================================================================================
 NOMBRE: [dbo].[usp_UpdateTurnoModificado]
 OBJETIVO: Actualizar parcialmente una modificación activa perteneciente a un turno.
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateTurnoModificado]
    @TurnoId INT,
    @TurnoModificadoId INT,
    @Fecha DATE = NULL,
    @HoraInicio TIME = NULL,
    @HoraFin TIME = NULL,
    @Motivo VARCHAR(255) = NULL,
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
            SET @Message = 'No se puede actualizar la modificación porque el turno tiene asistencias asociadas';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM TurnoModificado TM
            INNER JOIN TurnoModificado Actual
                ON Actual.TurnoModificadoId = @TurnoModificadoId
            WHERE TM.TurnoId = @TurnoId
                AND TM.UsuarioId = Actual.UsuarioId
                AND TM.Fecha = COALESCE(@Fecha, Actual.Fecha)
                AND TM.TurnoModificadoId <> @TurnoModificadoId
                AND TM.Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una modificación activa para el usuario y fecha indicados';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE TurnoModificado
        SET Fecha = COALESCE(@Fecha, Fecha),
            HoraInicio = COALESCE(@HoraInicio, HoraInicio),
            HoraFin = COALESCE(@HoraFin, HoraFin),
            Motivo = COALESCE(@Motivo, Motivo),
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE TurnoModificadoId = @TurnoModificadoId
            AND TurnoId = @TurnoId
            AND Eliminado = 0;

        SET @State = 1;
        SET @Message = 'Modificación de turno actualizada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
