IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_DeleteDetalleBiometrico'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_DeleteDetalleBiometrico]
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteDetalleBiometrico]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Eliminar (lógicamente) un detalle biométrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_DeleteDetalleBiometrico] @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message NVARCHAR(200) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        SET NOCOUNT ON;

        IF NOT EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE id = @id
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El detalleBiometrico, no existe o está eliminado';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico AS DB
                INNER JOIN Biometrico AS B
                    ON B.id = DB.biometricoId_fk
                WHERE DB.id = @ID
                    AND DB.bEliminado = 0
                    AND B.bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'Este detalle está vinculado a un biométrico.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM AsistenciaRegular
                WHERE detalleBiometricoId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'Esta siendo usado, en AsistenciRegular';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM AsistenciaExtendida
                WHERE detalleBiometricoId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'Esta siendo usado, en AsistenciExtendida';

            RETURN;
        END;

        UPDATE DetalleBiometrico
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la eliminacion.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO


