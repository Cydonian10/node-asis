IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_DeleteEstadoAsistencia'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_DeleteEstadoAsistencia];
GO

/*======================================================================================================
NOMBRE: [DBO].[usp_DeleteEstadoAsistencia]
FECHA: 25-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Eliminar datos de control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_DeleteEstadoAsistencia] @ID INT
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
                FROM EstadoAsistencia
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El estado asistencia no existe o ha sido eliminado';

            RETURN
        END

        IF EXISTS (
                SELECT 1
                FROM ControlRolUsuarioAsistencia
                WHERE estadoAsistenciaId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El estado asistencia está en uso.';

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM ControlUnidadAsistencia
                WHERE estadoAsistenciaId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El estado asistencia está en uso.';

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM RolControlAsistencia
                WHERE estadoAsistenciaId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El estado asistencia está en uso.';

            RETURN;
        END

        UPDATE EstadoAsistencia
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


