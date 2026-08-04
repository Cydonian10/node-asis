/*======================================================================================================
NOMBRE: [dbo].[usp_InsertTurnoExtendido]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite el registro de nuevos turnos extendidos.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertTurnoExtendido]
    @HORARIODIASID INT
    ,@HORAINICIO TIME
    ,@HORAFIN TIME
    ,@USER INT
    ,@State INT OUTPUT
    ,@Message VARCHAR(255) OUTPUT
    ,@Id INT OUTPUT
    ,@CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT

    BEGIN TRY
        IF @HORAINICIO IS NULL
        BEGIN
        SET @State = - 2;
        SET @Message = 'Debe especificar una hora de inicio válida.';

        RETURN;
    END;

        IF @HORAFIN IS NULL
        BEGIN
        SET @State = - 3;
        SET @Message = 'Debe especificar una hora de fin válida.';

        RETURN;
    END;

        IF NOT EXISTS (
                SELECT 1
    FROM HorarioDias
    WHERE id = @HORARIODIASID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 4;
        SET @Message = 'El horarioDía no existe o está eliminado';

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
        SET @State = - 5;
        SET @Message = 'No se puede registrar, este día está marcado como libre.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM TurnoExtendido
    WHERE horarioDiasId_fk = @HORARIODIASID
        AND horaInicio = @HORAINICIO
        AND horaFin = @HORAFIN
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 6;
        SET @Message = 'Ya existe un turno para este mismo horario';

        RETURN;
    END;

        -- IF EXISTS (
        --         SELECT 1
        --         FROM TurnoExtendido
        --         WHERE horaInicio = @HORAINICIO
        --             AND horaFin = @HORAFIN
        --             AND bEliminado = 0
        --         )
        -- BEGIN
        --     SET @State = - 7;
        --     SET @Message = 'Existe este turno en otro diferente horarioDía';

        --     RETURN;
        -- END;

          IF EXISTS (
            SELECT 1
    FROM TurnoRegular TR_Entrada
    CROSS JOIN TurnoRegular TR_Salida
    WHERE TR_Entrada.horarioDiasId_fk = @HORARIODIASID AND TR_Entrada.bEliminado = 0
        AND TR_Entrada.bTipo = 0
        AND TR_Salida.bTipo = 1
        AND TR_Entrada.horarioDiasId_fk =  TR_Salida.horarioDiasId_fk
        AND ((
              @HORAINICIO < TR_Salida.horaInicio
        AND @HORAFIN > TR_Entrada.horaInicio
            ))
        )
        BEGIN
        SELECT @State = -7, @Message = 'El rango de horas coincide con un turno regular ya existente.';
        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM TurnoExtendido
    WHERE horarioDiasId_fk = @HORARIODIASID
        AND bEliminado = 0
        AND (
                        -- turno normal
                        (
                            horaInicio < horaFin
        AND (
                                @HORAINICIO < horaFin
        AND @HORAFIN > horaInicio
                                )
                            )
        OR
        -- Turno para medianoche
        (
                            (
                                horaInicio > horaFin
        AND (
                                    (
                                        @HORAINICIO >= horaInicio
        OR @HORAINICIO < horaFin
                                        )
        OR (
                                        @HORAFIN > horaInicio
        OR @HORAFIN <= horaFin
                                        )
                                    )
                                )
                            )
                        )
                )
        BEGIN
        SET @State = - 8;
        SET @Message = 'El rango de horas coincide con otro turno existente';

        RETURN;
    END;

        INSERT INTO TurnoExtendido
        (
        horarioDiasId_fk
        , horaInicio
        , horaFin
        , nCreatedBy
        , tCreatedAt
        )
    VALUES
        (
            @HORARIODIASID
            , @HORAINICIO
            , @HORAFIN
            , @USER
            , GETDATE()
            );

        SET @Id = SCOPE_IDENTITY();
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Turno Extendido creado correctamente.';
    END
        ELSE
        BEGIN
        SET @State = - 1;
        SET @Message = 'Fallo en la inserción.';
    END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO
