/*======================================================================================================
NOMBRE: [dbo].[usp_UnitWorkMigrarSyncUsuario]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Migrar un usuario sincronizado a la tabla Usuario. Si @SyncUsuarioId es NULL, migra todos
          los registros de SyncUsuarios que aun no tienen fila en Usuario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnitWorkMigrarSyncUsuario]
    -- Parametros de entrada
    @SyncUsuarioId INT = NULL,
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
        IF @SyncUsuarioId IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM SyncUsuarios WHERE SyncUsuarioId = @SyncUsuarioId)
            BEGIN
                SET @State = -1;
                SET @Message = 'El usuario sincronizado no existe';
                SET @CodeError = -1;
                RETURN;
            END

            IF EXISTS (SELECT 1 FROM Usuario WHERE SyncUsuarioId = @SyncUsuarioId)
            BEGIN
                SET @State = -1;
                SET @Message = 'El usuario sincronizado ya fue migrado';
                SET @CodeError = -1;
                RETURN;
            END
        END

        BEGIN TRANSACTION;

        IF @SyncUsuarioId IS NOT NULL
        BEGIN
            INSERT INTO Usuario (SyncUsuarioId, Active, Eliminado)
            VALUES (@SyncUsuarioId, 1, 0);

            SET @Id = SCOPE_IDENTITY();
            SET @Message = 'Usuario migrado correctamente';
        END
        ELSE
        BEGIN
            INSERT INTO Usuario (SyncUsuarioId, Active, Eliminado)
            SELECT SU.SyncUsuarioId, 1, 0
            FROM SyncUsuarios SU
            LEFT JOIN Usuario U ON U.SyncUsuarioId = SU.SyncUsuarioId
            WHERE U.UsuarioId IS NULL;

            SET @Id = SCOPE_IDENTITY();
            SET @Message = 'Usuarios migrados correctamente';
        END

        COMMIT TRANSACTION;

        SET @State = 1;
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
