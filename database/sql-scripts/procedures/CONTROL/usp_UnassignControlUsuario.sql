/*======================================================================================================
NOMBRE: [dbo].[usp_UnassignControlUsuario]
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Eliminar logicamente la asignacion activa de un control hacia un usuario. Libera el usuario
          para poder asignarle otro control.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnassignControlUsuario]
    @ControlId INT,
    @UsuarioId INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 FROM ControlUsuario
            WHERE ControlId = @ControlId AND UsuarioId = @UsuarioId AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'La asignacion del control al usuario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE ControlUsuario
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE ControlId = @ControlId AND UsuarioId = @UsuarioId;

        SET @State = 1;
        SET @Message = 'Control desasignado del usuario correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO