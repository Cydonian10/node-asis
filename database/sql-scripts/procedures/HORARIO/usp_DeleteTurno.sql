/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteTurno]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Soft-delete de un turno (Eliminado = 1).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteTurno]
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
        IF NOT EXISTS (SELECT 1 FROM Turno WHERE TurnoId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno no existe';
            SET @CodeError = -1;
            RETURN;
        END

        -- No permitir eliminar un turno ligado a movimientos (asistencia, turno modificado,
        -- permiso o justificacion).
        IF EXISTS (
            SELECT 1
            FROM Turno T
            WHERE T.TurnoId = @ID AND T.Eliminado = 0
                AND (
                    EXISTS (SELECT 1 FROM Asistencia A WHERE A.turnoId = T.TurnoId)
                    OR EXISTS (SELECT 1 FROM TurnoModificado TM WHERE TM.TurnoId = T.TurnoId AND TM.Eliminado = 0)
                    OR EXISTS (SELECT 1 FROM Permisos P WHERE P.TurnoId = T.TurnoId)
                    OR EXISTS (SELECT 1 FROM Justificaciones J WHERE J.TurnoId = T.TurnoId)
                )
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno tiene asistencias o movimientos (permiso, justificacion) y no puede eliminarse';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Turno
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE TurnoId = @ID;

        SET @State = 1;
        SET @Message = 'Turno eliminado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
