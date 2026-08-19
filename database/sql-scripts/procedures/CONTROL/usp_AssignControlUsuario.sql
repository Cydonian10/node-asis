/*======================================================================================================
NOMBRE: [dbo].[usp_AssignControlUsuario]
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Asignar un control activo a un usuario activo. Solo se permite una asignacion activa por usuario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_AssignControlUsuario]
    @ControlId INT,
    @UsuarioId INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM [Control] WHERE ControlId = @ControlId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El control no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Usuario WHERE UsuarioId = @UsuarioId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El usuario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM ControlUsuario WHERE UsuarioId = @UsuarioId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El usuario ya tiene un control asignado';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO ControlUsuario (ControlId, UsuarioId, CreatedBy, UpdatedBy)
        VALUES (@ControlId, @UsuarioId, @USER, @USER);

        SET @Id = CONVERT(INT, SCOPE_IDENTITY());
        SET @State = 1;
        SET @Message = 'Control asignado al usuario correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO