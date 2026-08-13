/*======================================================================================================
NOMBRE: [dbo].[usp_CreateSyncUsuario]
FECHA: 13-08-2026
AUTOR: Gabriel
OBJETIVO: Crear un registro en SyncUsuarios. Si no se envia @SyncUsuarioId, se asigna MAX+1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateSyncUsuario]
    -- Parametros de entrada
    @SyncUsuarioId INT = NULL,
    @Usuario VARCHAR(200) = NULL,
    @Nombres VARCHAR(200) = NULL,
    @Apellidos VARCHAR(200) = NULL,
    @Tipo VARCHAR(50) = NULL,
    @Dni VARCHAR(20) = NULL,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF LTRIM(RTRIM(ISNULL(@Usuario, ''))) = ''
        BEGIN
            SET @State = -1;
            SET @Message = 'El usuario es requerido';
            SET @CodeError = -1;
            RETURN;
        END

        IF @SyncUsuarioId IS NULL
        BEGIN
            SELECT @SyncUsuarioId = ISNULL(MAX(SyncUsuarioId), 0) + 1 FROM SyncUsuarios;
        END

        IF EXISTS (SELECT 1 FROM SyncUsuarios WHERE SyncUsuarioId = @SyncUsuarioId)
        BEGIN
            SET @State = -1;
            SET @Message = 'El usuario sincronizado ya existe';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO SyncUsuarios (SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
        VALUES (@SyncUsuarioId, @Usuario, @Nombres, @Apellidos, @Tipo, @Dni);

        SET @Id = @SyncUsuarioId;
        SET @State = 1;
        SET @Message = 'Usuario sincronizado creado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
