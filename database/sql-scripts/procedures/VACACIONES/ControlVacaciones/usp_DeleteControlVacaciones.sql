/*======================================================================================================
NOMBRE: [DBO].[usp_DeleteControlVacaciones]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Eliminar datos de control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_DeleteControlVacaciones] 
    @ID INT
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
                FROM ControlVacaciones
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El periodo vacacional no existe o ha sido eliminado';

            RETURN
        END

        IF EXISTS (
                SELECT 1
                FROM PeriodoVacacional
                WHERE controlVacacionalId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El control vacacional está en uso.';

            RETURN;
        END

        UPDATE ControlVacaciones
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdateAt = GETDATE()
        WHERE id = @ID;

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
