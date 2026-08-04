IF EXISTS (
  SELECT *
FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'usp_UpdateCancelarCita'
    AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE [dbo].[usp_UpdateCancelarCita]
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateCancelarCita]
FECHA: 07-10-2025
AUTOR: Jesamine M. Ramón Yora
OBJETIVO: Permite cancelar una cita (marcarla como cancelada sin eliminarla del registro).

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
01    06/01/2026   fluna         añadir activacion de cita
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_UpdateCancelarCita]
    @ID INT
    ,@USER INT
    ,@State INT OUTPUT
    ,@Message VARCHAR(255) OUTPUT
    ,@CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Cita
                WHERE id = @ID
                AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El registro no existe o ya fue eliminado.';
            RETURN;
        END;
        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE id = @ID
                AND bCancelado = 1
                )
        BEGIN
            UPDATE Cita
            SET bCancelado = 0
                , nUpdatedBy = @USER
                , tUpdatedAt = GETDATE()
               WHERE id = @ID
                 AND bEliminado = 0;
            IF @@ROWCOUNT > 0
            BEGIN
                SET @State = 0;
                SET @Message = 'La cita fue activada correctamente.';
            END
            ELSE
            BEGIN
                SET @State = - 1;
                SET @Message = 'No se pudo activar la cita.';
            END
        END
        ELSE BEGIN
            UPDATE Cita
            SET bCancelado = 1
                , nUpdatedBy = @USER
                , tUpdatedAt = GETDATE()
                WHERE id = @ID
                AND bEliminado = 0;
        IF @@ROWCOUNT > 0
            BEGIN
                SET @State = 0;
                SET @Message = 'La cita fue cancelada correctamente.';
            END
            ELSE
            BEGIN
                SET @State = - 1;
                SET @Message = 'No se pudo cancelar la cita.';
            END;
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO
-- GRANT EXECUTE ON [dbo].[usp_UpdateCancelarCita] TO u_r_sgicomplejo
-- GO