IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_DeleteRolDeUsuario'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_DeleteRolDeUsuario]
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteRolesDeUsuario]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar roles asignados a usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_DeleteRolDeUsuario]
    @ROL_USUARIO_ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        -- Validar si existe el rol y está en uso en otras tablas
        IF NOT EXISTS (
                SELECT 1
                FROM RolUsuario
                WHERE id = @ROL_USUARIO_ID
                    -- AND usuarioId_fk = @USUARIOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El registro no existe o ya ha sido eliminado.';
            SET @CodeError = - 1;

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM RolUsuario RU
                WHERE RU.id = @ROL_USUARIO_ID
                    -- AND RU.rolId_fk = @ROLID
                    AND RU.bEliminado = 0
                    AND (
                        EXISTS (
                            SELECT 1
                            FROM GradoSupervisado GS
                            WHERE GS.rolUsuarioId_pk = RU.id
                            )
                        OR EXISTS (
                            SELECT 1
                            FROM Retirado RE
                            WHERE RE.rolUsuarioid_fk = RU.id
                            )
                        OR EXISTS (
                            SELECT 1
                            FROM HorarioUsuario HO
                            WHERE HO.rolUsuarioid_fk = RU.id
                            )
                        OR EXISTS (
                            SELECT 1
                            FROM ControlRolUsuario CORO
                            WHERE CORO.rolUsuarioid_fk = RU.id
                            )
                        )
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se puede eliminar el rolUsuario porque está en uso [Control Rol] [Horario Usuario] [Retirado] [Grado Supervisado]';
            SET @CodeError = - 1;

            RETURN;
        END

        -- Marcar como eliminado
        UPDATE RolUsuario
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ROL_USUARIO_ID
            -- AND rolId_fk = @ROLID
            AND bEliminado = 0;

        SET @State = 1;
        SET @Message = 'Rol eliminado correctamente';
        SET @CodeError = 0;
    END TRY

    BEGIN CATCH
        SET @State = - 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
