/*======================================================================================================
NOMBRE: [dbo].[usp_UnitWorkAsignarUsuariosArea]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Asignar en lote sync-usuarios a un area. Para cada SyncUsuarioId del TVP:
          - si ya existe Usuario con ese SyncUsuarioId, actualiza su AreaId;
          - si no existe, crea el Usuario (Active = 1, EsSupervisor = 0, Eliminado = 0).
          Es la unica via de crear usuarios (SPEC 04): la migracion sync->usuario dejo de ser un paso
          separado. No hay loop row-by-row; cada sentencia es set-based dentro de transaccion.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnitWorkAsignarUsuariosArea]
    -- Parametros de entrada
    @AreaId INT,
    @SyncUsuarioIds dbo.IntListTableType READONLY,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area WHERE AreaId = @AreaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El area no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM @SyncUsuarioIds ids
            WHERE NOT EXISTS (
                SELECT 1 FROM SyncUsuarios SU
                WHERE SU.SyncUsuarioId = ids.Value
            )
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Los usuarios sincronizados deben existir';
            SET @CodeError = -1;
            RETURN;
        END

        BEGIN TRANSACTION;

        INSERT INTO Usuario (SyncUsuarioId, Active, AreaId, EsSupervisor, Eliminado)
        SELECT ids.Value, 1, @AreaId, 0, 0
        FROM @SyncUsuarioIds ids
        WHERE NOT EXISTS (
            SELECT 1 FROM Usuario U
            WHERE U.SyncUsuarioId = ids.Value
        );

        UPDATE U
        SET U.AreaId = @AreaId,
            U.UpdatedAt = GETDATE()
        FROM Usuario U
        INNER JOIN @SyncUsuarioIds ids ON ids.Value = U.SyncUsuarioId
        WHERE U.Eliminado = 0;

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Usuarios asignados al area correctamente';
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
