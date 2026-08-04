/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateUsuarioActivo]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Activar o desactivar un usuario (columna Active).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateUsuarioActivo]
    -- Parametros de entrada
    @ID INT,
    @Activo BIT,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Usuario WHERE UsuarioId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El usuario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Usuario
        SET Active = @Activo,
            UpdatedAt = GETDATE()
        WHERE UsuarioId = @ID;

        SET @State = 1;
        SET @Message = 'Usuario actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
