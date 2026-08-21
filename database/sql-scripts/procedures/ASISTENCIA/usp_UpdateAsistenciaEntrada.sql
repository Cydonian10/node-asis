/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateAsistenciaEntrada]
OBJETIVO: Actualizar la entrada, su estado, los minutos de tardanza y el resultado de una asistencia.
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateAsistenciaEntrada]
    @AsistenciaId INT,
    @HoraEntrada DATETIME2,
    @EstadoEntradaId INT,
    @MinutosTarde INT,
    @ResultadoAsistencia VARCHAR(50),
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Asistencia WHERE AsistenciaId = @AsistenciaId)
        BEGIN
            SET @State = -1;
            SET @Message = 'La asistencia no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Asistencia
        SET HoraEntrada = @HoraEntrada,
            EstadoAsistenciaEntradaId = @EstadoEntradaId,
            MinutosTarde = @MinutosTarde,
            ResultadoAsistencia = @ResultadoAsistencia,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE AsistenciaId = @AsistenciaId;

        SET @State = 1;
        SET @Message = 'Entrada actualizada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
