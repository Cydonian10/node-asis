SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteHorario]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite Eliminar un horario que no este en uso.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER   PROCEDURE [dbo].[usp_DeleteHorario]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1
    FROM Horario
    WHERE id = @ID AND bEliminado = 0)
        BEGIN
        SELECT @State = -2, @Message = 'El horario no existe o ya ha sido eliminado.';
        RETURN;
    END

        --  Validar si está asignado a usuarios 
    --     IF EXISTS (SELECT 1
    -- FROM HorarioUsuario
    -- WHERE horarioId_fk = @ID AND bEliminado = 0)
    --     BEGIN
    --     SELECT @State = -3, @Message = 'El horario está asignado a un usuario activo, no se puede eliminar.';
    --     RETURN;
    -- END

        IF EXISTS (
            SELECT 1
        FROM AsistenciaRegular AR
            INNER JOIN TurnoRegular TR ON AR.TurnoRegularId_fk = TR.id
            INNER JOIN HorarioDias HD ON TR.horarioDiasId_fk = HD.id
        WHERE HD.horarioId_fk = @ID
        ) OR EXISTS (
            SELECT 1
        FROM AsistenciaExtendida AE
            INNER JOIN TurnoExtendido TE ON AE.TurnoExtendidoId_fk = TE.id
            INNER JOIN HorarioDias HD ON TE.horarioDiasId_fk = HD.id
        WHERE HD.horarioId_fk = @ID
        )
        BEGIN
        SELECT @State = -5, @Message = 'El horario ya cuenta con registros de asistencia. No se puede eliminar.';
        RETURN;
    END

        BEGIN TRANSACTION;
            
            UPDATE TM
            SET bEliminado = 1
            FROM TurnoModificado TM
            INNER JOIN TurnoRegular TR ON TM.turnoRegularId_fk = TR.id
            INNER JOIN HorarioDias HD ON TR.horarioDiasId_fk = HD.id
            WHERE HD.horarioId_fk = @ID AND TM.bEliminado = 0;

            UPDATE TR
            SET bEliminado = 1
            FROM TurnoRegular TR
            INNER JOIN HorarioDias HD ON TR.horarioDiasId_fk = HD.id
            WHERE HD.horarioId_fk = @ID AND TR.bEliminado = 0;

            UPDATE TE
            SET bEliminado = 1
            FROM TurnoExtendido TE
            INNER JOIN HorarioDias HD ON TE.horarioDiasId_fk = HD.id
            WHERE HD.horarioId_fk = @ID AND TE.bEliminado = 0;

            UPDATE Vigencia 
            SET bEliminado = 1
            FROM Vigencia V
            INNER JOIN HorarioDias HD ON V.horarioDiasId_fk = HD.id
            WHERE HD.horarioId_fk = @ID AND V.bEliminado = 0;

            UPDATE HorarioDias
            SET bEliminado = 1
            WHERE horarioId_fk = @ID AND bEliminado = 0;
            
            UPDATE HorarioUsuario 
            SET bEliminado = 1 
            WHERE horarioId_fk = @ID AND bEliminado = 0

            UPDATE Horario
            SET bEliminado = 1, 
                nUpdatedBy = @USER, 
                tUpdatedAt = GETDATE()
            WHERE id = @ID;

        COMMIT TRANSACTION;

        SET @State = 0;
        SET @Message = 'Horario eliminado correctamente.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
