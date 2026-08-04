SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertGradoSupervisado]
FECHA: 25-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar estado de asitencia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertGradoSupervisado] @IDGRADO INT
    , @IDROLUSUARIO INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        IF NOT EXISTS (
                SELECT 1
                FROM Sync_GradoNivel
                WHERE idGrado = @IDGRADO
           --         AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El grado especificado no existe o fue eliminado.';

            RETURN;
        END

        IF NOT EXISTS (
                SELECT 1
                FROM RolUsuario
                WHERE id = @IDROLUSUARIO
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El rol de usuario especificado no existe o fue eliminado.';

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM GradoSupervisado
                WHERE idGrado_pk = @IDGRADO
                    AND rolUsuarioId_pk = @IDROLUSUARIO
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El grado supervisado ya se encuentra registrado.';
        END

        INSERT INTO GradoSupervisado (
            idGrado_pk
            , rolUsuarioId_pk
            , nCreatedBy
            )
        VALUES (
            @IDGRADO
            , @IDROLUSUARIO
            , @USER
            )

        SET @Id = SCOPE_IDENTITY()
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

