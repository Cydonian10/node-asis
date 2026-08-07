/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteHorario]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Soft-delete en cascada de un horario: marca Eliminado = 1 en Horario, HorarioDia, Turno,
          Vigencia y HorarioAsignacion. Verifica restricciones: no debe haber filas en Asistencia ni
          en Vacaciones que referencien el horario (esas tablas no tienen flag Eliminado, cuentan todas).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteHorario]
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
        IF NOT EXISTS (SELECT 1 FROM Horario WHERE HorarioId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El horario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Asistencia WHERE HorarioId = @ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar el horario porque tiene asistencias asociadas (Asistencia)';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Vacaciones WHERE HorarioId = @ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar el horario porque tiene vacaciones asociadas (Vacaciones)';
            SET @CodeError = -1;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE Horario SET Eliminado = 1, UpdatedAt = GETDATE(), UpdatedBy = @USER WHERE HorarioId = @ID;

        UPDATE HD
        SET HD.Eliminado = 1, HD.UpdatedAt = GETDATE(), HD.UpdatedBy = @USER
        FROM HorarioDia HD
        WHERE HD.HorarioId = @ID AND HD.Eliminado = 0;

        UPDATE T
        SET T.Eliminado = 1, T.UpdatedAt = GETDATE(), T.UpdatedBy = @USER
        FROM Turno T
        INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
        WHERE HD.HorarioId = @ID AND T.Eliminado = 0;

        UPDATE V
        SET V.Eliminado = 1, V.UpdatedAt = GETDATE(), V.UpdatedBy = @USER
        FROM Vigencia V
        INNER JOIN HorarioDia HD ON HD.HorarioDiaId = V.HorarioDiaId
        WHERE HD.HorarioId = @ID AND V.Eliminado = 0;

        UPDATE HA
        SET HA.Eliminado = 1, HA.UpdatedAt = GETDATE(), HA.UpdatedBy = @USER
        FROM HorarioAsignacion HA
        WHERE HA.HorarioId = @ID AND HA.Eliminado = 0;

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Horario eliminado correctamente';
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
