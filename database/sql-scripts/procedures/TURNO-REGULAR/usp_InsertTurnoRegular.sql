/*======================================================================================================
NOMBRE: [dbo].[usp_InsertTurnoRegular]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite registrar nuevos turnos regulares.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertTurnoRegular]
    @HORARIODIASID INT
    ,@HORAINICIO TIME
    ,@TIPO BIT
    ,@USER INT
    ,@State INT OUTPUT
    ,@Message VARCHAR(255) OUTPUT
    ,@Id INT OUTPUT
    ,@CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NuevoOrden INT = 0;
    SET @Id = 0;
    SET @CodeError = 0;

    BEGIN TRY
        IF @HORAINICIO IS NULL OR @HORAINICIO = '00:00:00'
        BEGIN
        SELECT @State = -3, @Message = 'Debe especificar una horaInicio válida.';
        RETURN;
    END;

        DECLARE @bLibre BIT;
        DECLARE @Existe BIT = 0;

        SELECT @Existe = 1, @bLibre = bLibre
    FROM HorarioDias
    WHERE id = @HORARIODIASID AND bEliminado = 0;

        IF @Existe IS NULL OR @Existe = 0
        BEGIN
        SELECT @State = -4, @Message = 'Horario Dias no existe o está eliminado';
        RETURN;
    END

        IF @bLibre = 1
        BEGIN
        SELECT @State = -5, @Message = 'No puedes registrar turnos, este día es libre.';
        RETURN;
    END
    IF EXISTS (
    SELECT 1
    FROM TurnoExtendido
    WHERE horarioDiasId_fk = @HORARIODIASID AND bEliminado = 0
        AND (@HORAINICIO <= horaFin AND @HORAINICIO >= horaInicio)
        ) 
        BEGIN
        SELECT @State = -8, @Message = 'El rango de horas coincide con un turno extendido ya existente.';
        RETURN;
         END;
        
    -- IF EXISTS (
    -- SELECT 1
    -- FROM TurnoRegular
    -- WHERE horarioDiasId_fk = @HORARIODIASID AND bEliminado = 0
    --     AND (@HORAINICIO <= horaInicio)
    --     )
    --     BEGIN
    --     SELECT @State = -8, @Message = 'La hora ingresada se superpone con otro turno.';
    --     RETURN;
    -- END;

        BEGIN TRANSACTION;
            
            SELECT @NuevoOrden = ISNULL(MAX(orden), 0) + 1
    FROM TurnoRegular WITH (UPDLOCK, HOLDLOCK)
    WHERE horarioDiasId_fk = @HORARIODIASID AND bEliminado = 0;

            IF EXISTS (
                SELECT 1
    FROM TurnoRegular
    WHERE horarioDiasId_fk = @HORARIODIASID
        AND horaInicio = @HORAINICIO
        AND bEliminado = 0
            )
            BEGIN
        ROLLBACK TRANSACTION;
        SELECT @State = -7, @Message = 'Ya existe un turno con la misma hora en este día.';
        RETURN;
    END

            INSERT INTO TurnoRegular
        (
        horarioDiasId_fk
        , orden
        , horaInicio
        , bTipo
        , nCreatedBy
        , tCreatedAt
        )
    VALUES
        (
            @HORARIODIASID
                , @NuevoOrden
                , @HORAINICIO
                , @TIPO
                , @USER
                , GETDATE()
            );

            SET @Id = SCOPE_IDENTITY();
            SELECT @State = 0, @Message = 'Turno Regular creado Correctamente. Orden asignado: ' + CAST(@NuevoOrden AS VARCHAR(10));

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
