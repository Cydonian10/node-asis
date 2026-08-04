/*======================================================================================================
NOMBRE: [dbo].[usp_UnitWorkAsignarUsuariosRolUnidad]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Asignar en lote usuarios a un rol-en-unidad. Inserta en una sola sentencia los usuarios
          del TVP que aun no tienen ese rol (respeta el UNIQUE de UsuarioRol). Si el usuario ya
          tiene el rol (aunque sea Eliminado = 1), se omite. No hay loop row-by-row.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnitWorkAsignarUsuariosRolUnidad]
    -- Parametros de entrada
    @RolUnidadId INT,
    @UsuarioIds dbo.IntListTableType READONLY,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM RolUnidad WHERE RolUnidadId = @RolUnidadId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El rol de la unidad no existe';
            SET @CodeError = -1;
            RETURN;
        END

        BEGIN TRANSACTION;

        INSERT INTO UsuarioRol (UsuarioId, RolUnidadId, CreatedBy, UpdatedBy)
        SELECT t.Value, @RolUnidadId, @USER, @USER
        FROM @UsuarioIds t
        WHERE NOT EXISTS (
            SELECT 1 FROM UsuarioRol ur
            WHERE ur.UsuarioId = t.Value AND ur.RolUnidadId = @RolUnidadId
        );

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Usuarios asignados al rol de la unidad correctamente';
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
