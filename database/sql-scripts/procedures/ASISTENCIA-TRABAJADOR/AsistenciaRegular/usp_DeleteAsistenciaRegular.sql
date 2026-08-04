SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteAsistenciaRegular]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Eliminar las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_DeleteAsistenciaRegular]
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
                FROM AsistenciaRegular
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1
            SET @Message = 'La asistencia no existe o ha sido eliminado';

            RETURN
        END

        UPDATE AsistenciaRegular
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
