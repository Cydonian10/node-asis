/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteHorarioDia]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Soft-delete en cascada de un HorarioDia: marca Eliminado = 1 en el HorarioDia y en sus
          Turnos y SalidaTurnoDia asociados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  1  14-08-2026  Gabriel    Quita Vigencia (tabla eliminada); borra SalidaTurnoDia.
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

        -- No permitir eliminar un dia que tenga turnos ligados a movimientos
        -- (asistencia, turno modificado, permiso o justificacion).
        IF EXISTS (
            SELECT 1
            FROM Turno T
            WHERE T.HorarioDiaId = @ID AND T.Eliminado = 0
                AND (
                    EXISTS (SELECT 1 FROM Asistencia A WHERE A.turnoId = T.TurnoId)
                    OR EXISTS (SELECT 1 FROM TurnoModificado TM WHERE TM.TurnoId = T.TurnoId AND TM.Eliminado = 0)
                    OR EXISTS (SELECT 1 FROM Permisos P WHERE P.TurnoId = T.TurnoId)
                    OR EXISTS (SELECT 1 FROM Justificaciones J WHERE J.TurnoId = T.TurnoId)
                )
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El dia tiene turnos con asistencias o movimientos (permiso, justificacion) y no puede eliminarse';
            SET @CodeError = -1;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE STD
        SET STD.Eliminado = 1, STD.UpdatedAt = GETDATE(), STD.UpdatedBy = @USER
        FROM SalidaTurnoDia STD
        INNER JOIN Turno T ON T.TurnoId = STD.TurnoId
        WHERE T.HorarioDiaId = @ID AND STD.Eliminado = 0;

        UPDATE T
        SET T.Eliminado = 1, T.UpdatedAt = GETDATE(), T.UpdatedBy = @USER
        FROM Turno T
        WHERE T.HorarioDiaId = @ID AND T.Eliminado = 0;

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
