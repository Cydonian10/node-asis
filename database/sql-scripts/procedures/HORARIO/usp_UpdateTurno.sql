/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateTurno]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar un turno (ISNULL sobre la columna actual). Solo actualiza las columnas enviadas.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateTurno]
    -- Parametros de entrada
    @ID INT,
    @HoraInicio TIME = NULL,
    @HoraFin TIME = NULL,
    @Extendido BIT = NULL,
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

        -- No permitir modificar un turno ligado a movimientos (asistencia, turno modificado,
        -- permiso o justificacion) cuando la peticion implica un cambio real.
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
                AND (
                    (@HoraInicio IS NOT NULL AND @HoraInicio <> T.HoraInicio)
                    OR (@HoraFin IS NOT NULL AND @HoraFin <> T.HoraFin)
                    OR (@Extendido IS NOT NULL AND @Extendido <> T.Extendido)
                )
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno tiene asistencias o movimientos (permiso, justificacion) y no puede modificarse';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Turno
        SET HoraInicio = ISNULL(@HoraInicio, HoraInicio),
            HoraFin = ISNULL(@HoraFin, HoraFin),
            Extendido = ISNULL(@Extendido, Extendido),
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE TurnoId = @ID;

        SET @State = 1;
        SET @Message = 'Turno actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
