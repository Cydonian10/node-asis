/*======================================================================================================
NOMBRE: [dbo].[usp_CulminarHorarioAsignacion]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Marcar una asignacion de horario como culminada (Culminacion = 1). Solo se permite asignar
          un nuevo horario a un usuario cuando todas sus asignaciones previas estan culminadas.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -    -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CulminarHorarioAsignacion]
    -- Parametros de entrada
    @HorarioAsignacionId INT,
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

        UPDATE HorarioAsignacion
        SET Culminacion = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE HorarioAsignacionId = @HorarioAsignacionId AND Eliminado = 0;

        SET @State = 1;
        SET @Message = 'Horario marcado como culminado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
