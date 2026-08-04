/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateTurnoExtendido]
FECHA: 17/10/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite la actualización de turnos extendidos.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateTurnoExtendido]
    @ID INT,
    @HORA_INICIO TIME = NULL,
    @HORA_FIN TIME = NULL,
    @HORARIO_DIA_ID INT = null,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE TurnoExtendido
        SET 
            horaInicio = COALESCE(@HORA_INICIO, horaInicio),
            horaFin = COALESCE(@HORA_FIN, horaFin),
            horarioDiasId_fk = COALESCE(@HORARIO_DIA_ID, horarioDiasId_fk),
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE 
            ID = @ID;

        IF @@ROWCOUNT = 0
        BEGIN
        SET @State = -1;
        SET @Message = 'No se encontró el turno extendido con el ID proporcionado.';
        SET @CodeError = 404;
        ROLLBACK TRANSACTION;
        RETURN;
    END;
          IF EXISTS (
            SELECT 1
    FROM TurnoRegular TR_Entrada
    CROSS JOIN TurnoRegular TR_Salida
    WHERE TR_Entrada.horarioDiasId_fk = @HORARIO_DIA_ID AND TR_Entrada.bEliminado = 0
        AND TR_Entrada.bTipo = 0
        AND TR_Salida.bTipo = 1
        AND TR_Entrada.horarioDiasId_fk =  TR_Salida.horarioDiasId_fk
        AND ((
              @HORA_INICIO < TR_Salida.horaInicio
        AND @HORA_FIN > TR_Entrada.horaInicio
            ))
        )
        BEGIN
        SELECT @State = -7, @Message = 'El rango de horas coincide con un turno regular ya existente.';
        ROLLBACK TRANSACTION;
        RETURN;
    END;
        IF EXISTS (
                SELECT 1
    FROM TurnoExtendido
    WHERE horarioDiasId_fk = @HORARIO_DIA_ID
        AND horaInicio = @HORA_INICIO
        AND horaFin = @HORA_FIN
        AND bEliminado = 0
        AND ID <> @ID 
                )
        BEGIN
        SET @State = -6;
        SET @Message = 'Ya existe un turno con la misma horaInicio y horaFin para este mismo horario.';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

        
        SET @State = 1;
        SET @Message = 'Turno extendido actualizado correctamente.';
        SET @CodeError = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END

