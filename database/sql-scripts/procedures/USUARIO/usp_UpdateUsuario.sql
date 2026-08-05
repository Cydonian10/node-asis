/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateUsuario]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar activo, area y/o flag esSupervisor de un usuario. Actualiza solo las columnas
          enviadas (ISNULL sobre la columna actual). Si se envia @AreaId, valida que el area exista
          y no este eliminada. Reemplaza a usp_UpdateUsuarioActivo (SPEC 04).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateUsuario]
    -- Parametros de entrada
    @ID INT,
    @Activo BIT = NULL,
    @AreaId INT = NULL,
    @EsSupervisor BIT = NULL,
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

        IF @AreaId IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM Area WHERE AreaId = @AreaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El area no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Usuario
        SET Active = ISNULL(@Activo, Active),
            AreaId = ISNULL(@AreaId, AreaId),
            EsSupervisor = ISNULL(@EsSupervisor, EsSupervisor),
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
