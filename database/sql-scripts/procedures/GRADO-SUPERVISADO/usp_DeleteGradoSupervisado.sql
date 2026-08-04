SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [DBO].[usp_DeleteGradoSupervisado]
FECHA: 06-10-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Eliminar datos de control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_DeleteGradoSupervisado] @IDGRADO INT
    , @IDROLUSUARIO INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM GradoSupervisado
                WHERE idGrado_pk = @IDGRADO
                    AND rolUsuarioId_pk = @IDROLUSUARIO
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El estado asistencia no existe o ha sido eliminado';

            RETURN
        END

        UPDATE GradoSupervisado
        SET bEliminado = 1
            -- , nUpdatedBy = @USER
            -- , tUpdateAt = GETDATE()
        WHERE idGrado_pk = @IDGRADO
            AND rolUsuarioId_pk = @IDROLUSUARIO;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1
            SET @Message = 'Fallo en la eliminacion';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

/*SELECT * FROM Sync_GradoNivel

INSERT INTO API_SCAP_DB.dbo.Sync_GradoNivel
(idGrado, cGrado, IdNivel, cNivel)
VALUES('1', '2', '1', 'Inicial');

UPDATE API_SCAP_DB.dbo.Sync_GradoNivel
SET cGrado='2 años', IdNivel='1', cNivel='Inicial'
WHERE idGrado='1';*/