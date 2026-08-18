/*======================================================================================================
NOMBRE: [dbo].[usp_ActualizarFechaFinHorarioAsignacion]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar la FechaFin (fecha de culminacion) de una asignacion de horario NO culminada,
          permitiendo extender su vigencia. Rechaza asignaciones culminadas o con FechaFin anterior a
          la FechaInicio.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -    -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_ActualizarFechaFinHorarioAsignacion]
    -- Parametros de entrada
    @HorarioAsignacionId INT,
    @FechaFin DATE,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM HorarioAsignacion
            WHERE HorarioAsignacionId = @HorarioAsignacionId AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'La asignación no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM HorarioAsignacion
            WHERE HorarioAsignacionId = @HorarioAsignacionId AND Culminacion = 1
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede editar la fecha de un horario ya culminado';
            SET @CodeError = -2;
            RETURN;
        END

        IF @FechaFin IS NOT NULL AND EXISTS (
            SELECT 1
            FROM HorarioAsignacion
            WHERE HorarioAsignacionId = @HorarioAsignacionId
              AND FechaInicio IS NOT NULL
              AND @FechaFin < FechaInicio
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'La fecha fin no puede ser anterior a la fecha inicio';
            SET @CodeError = -3;
            RETURN;
        END

        UPDATE HorarioAsignacion
        SET FechaFin = @FechaFin,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE HorarioAsignacionId = @HorarioAsignacionId AND Eliminado = 0;

        SET @State = 1;
        SET @Message = 'Fecha de culminación actualizada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
