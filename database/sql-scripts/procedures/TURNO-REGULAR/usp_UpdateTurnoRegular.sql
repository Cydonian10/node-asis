/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateTurnoRegular]
FECHA: 17-09-2025
AUTOR: Jesamine R. Yora
OBJETIVO: Permite actualizar un turno regular existente

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateTurnoRegular]
    @ID INT
    ,@HORARIODIASID INT = NULL
    ,@ORDEN INT = NULL
    ,@HORAINICIO TIME = NULL
    ,@TIPO BIT
    ,@USER INT
    ,@State INT OUTPUT
    ,@Message VARCHAR(255) OUTPUT
    ,@CodeError INT OUTPUT
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
        SET @State = - 2;
        SET @Message = 'El turno no existe o está eliminado.';

        RETURN;
    END;

        -- IF @ORDEN IS NULL
        --     OR @ORDEN <= 0
        -- BEGIN
        --     SET @State = - 3;
        --     SET @Message = 'Especifique un orden válido.';

        --     RETURN;
        -- END;

        IF @HORAINICIO IS NULL
        OR @HORAINICIO = '00:00:00'
        BEGIN
        SET @State = - 4;
        SET @Message = 'Especifique una horaInicio valida.';

        RETURN;
    END;

        IF NOT EXISTS (
                SELECT 1
    FROM HorarioDias
    WHERE id = @HORARIODIASID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 5;
        SET @Message = 'El horarioDias no existe o esta eliminado.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM HorarioDias
    WHERE id = @HORARIODIASID
        AND bLibre = 1
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 6;
        SET @Message = 'No se pueden registrar turnos, el dia es libre.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM TurnoRegular
    WHERE horarioDiasId_fk = @HORARIODIASID
        AND orden = @ORDEN
        AND id <> @ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 7;
        SET @Message = 'Ya existe un turno con este orden en el horario.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM TurnoRegular
    WHERE horarioDiasId_fk = @HORARIODIASID
        AND horaInicio = @HORAINICIO
        AND id <> @ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 8;
        SET @Message = 'Ya existe un turno con la misma hora en este horario.';

        RETURN;
    END;
           IF EXISTS (
            SELECT 1
    FROM TurnoExtendido
        WHERE horarioDiasId_fk = @HORARIODIASID AND bEliminado = 0
            AND (@HORAINICIO <= horaFin AND @HORAINICIO >= horaInicio)
            ) 
            BEGIN
            SELECT @State = -8, @Message = 'El rango de horas coincide con un turno Extendido ya existente.';
            RETURN;
        END;
            
    --     IF EXISTS (
    --         SELECT 1 
    --         FROM TurnoRegular 
    --         WHERE horarioDiasId_fk = @HORARIODIASID AND bEliminado = 0 
    --             AND (@HORAINICIO <= horaInicio)
                  
    --     )
    --     BEGIN
    --     SELECT @State = -8, @Message = 'La hora ingresada se superpone con otro turno.';
    --     RETURN;
    -- END;

        UPDATE TurnoRegular
        SET horarioDiasId_fk = COALESCE(@HORARIODIASID, horarioDiasId_fk)
       --     , orden = COALESCE(@ORDEN, orden)
            , horaInicio = COALESCE(@HORAINICIO, horaInicio)
            , bTipo = @TIPO
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
        AND bEliminado = 0;

        IF (@@ROWCOUNT > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Actualización exitosa.';
    END
        ELSE
        BEGIN
        SET @State = - 1;
        SET @Message = 'No se encontró el registro o ya está eliminado.';
    END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
