IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_DeleteLicencia'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_DeleteLicencia];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteLicencia]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite eliminar una licencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_DeleteLicencia] @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Licencia
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'La licencia no existe o ya fue eliminada.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia AS L
                INNER JOIN Motivo AS M
                    ON M.id = L.motivoId_fk
                WHERE L.id = @ID
                    AND L.bEliminado = 0
                    AND M.bEliminado = 0
                )
        BEGIN
            SET @State = - 3
            SET @Message = 'La licencia tiene un motivo asignado'

            RETURN;
        END

        UPDATE Licencia
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la eliminación';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO


