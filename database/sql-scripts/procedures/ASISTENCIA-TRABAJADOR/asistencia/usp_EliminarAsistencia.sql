SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_EliminarAsistencia]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Elimina lógicamente un registro de asistencia (marcándolo como eliminado)

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_EliminarAsistencia]
    @ASISTENCIA_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM AsistenciaRegular
            WHERE asistenciaId_fk = @ASISTENCIA_ID AND bEliminado = 0)
            BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: el está vinculada a [Asistencia Regular].';
            SET @CodeError = -1;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        IF NOT EXISTS (
            SELECT 1
            FROM Asistencia
            WHERE id = @ASISTENCIA_ID AND bEliminado = 0)
            BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró la asistencia o ya fue eliminada.';
            SET @CodeError = -1;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE Asistencia
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ASISTENCIA_ID;

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Asistencia eliminada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
