IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_InsertRolAUsuario'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_InsertRolAUsuario];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertRolAUsuario]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear rol que se va supervisaar en el sistema

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_InsertRolAUsuario] @USUARIOID INT
    , @ROLID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Sync_Usuario
                WHERE id = @USUARIOID
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El usuario no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Rol
                WHERE id = @ROLID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El rol no existe o está eliminado.';

            RETURN;
        END;

        -- Validar si ya existe la asignación activa
        IF EXISTS (
                SELECT 1
                FROM RolUsuario AS RU
                WHERE RU.usuarioId_fk = @USUARIOID
                    AND RU.rolId_fk = @ROLID
                    AND RU.bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El usuario ya tiene asignado este rol.';

            RETURN;
        END

        -- Insertar nueva relación
        INSERT INTO API_SCAP_DB.dbo.RolUsuario (
            usuarioId_fk
            , rolId_fk
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @USUARIOID
            , @ROLID
            , @USER
            , GETDATE()
            );

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Rol asignado correctamente';
        SET @CodeError = 0;
    END TRY

    BEGIN CATCH
        SET @Id = 0;
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO


