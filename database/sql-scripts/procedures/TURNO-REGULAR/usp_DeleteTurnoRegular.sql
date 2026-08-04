/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteTurnoRegular]
FECHA: 17-09-2025
AUTOR: Jesamine R. Yora
OBJETIVO: Permite eliminar un turno regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteTurnoRegular] @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM TurnoRegular
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El turnoRegular no existe o ha sido eliminado'

            RETURN
        END

        IF EXISTS (
                SELECT 1
                FROM AsistenciaRegular
                WHERE turnoRegularId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3
            SET @Message = 'El turno esta en uso, en AsistenciaRegular'

            RETURN
        END

        IF EXISTS (
                SELECT 1
                FROM TurnoModificado
                WHERE turnoRegularId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El turno esta en uso, tiene Turnos Modificados activos.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM JustificacionTurnoRegular
                WHERE turnoRegularId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5
            SET @Message = 'El turno esta en uso, tienne JustificacionTurnoRegular'

            RETURN
        END

        UPDATE TurnoRegular
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación  exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
