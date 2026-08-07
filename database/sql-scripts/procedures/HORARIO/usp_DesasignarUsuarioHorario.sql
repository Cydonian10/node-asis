/*======================================================================================================
NOMBRE: [dbo].[usp_DesasignarUsuarioHorario]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Desasignar un usuario de un horario: soft-delete de la HorarioAsignacion activa.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DesasignarUsuarioHorario]
    -- Parametros de entrada
    @HorarioId INT,
    @UsuarioId INT,
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
            SELECT 1 FROM HorarioAsignacion
            WHERE HorarioId = @HorarioId AND UsuarioId = @UsuarioId AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'La asignacion no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE HorarioAsignacion
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE HorarioId = @HorarioId AND UsuarioId = @UsuarioId AND Eliminado = 0;

        SET @State = 1;
        SET @Message = 'Usuario desasignado del horario correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
