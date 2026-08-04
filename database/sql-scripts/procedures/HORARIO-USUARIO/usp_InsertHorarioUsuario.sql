/*======================================================================================================
NOMBRE: [dbo].[usp_InsertHorarioUsuario]
FECHA: 25-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar estado de asitencia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertHorarioUsuario]
    @IDHORARIO INT
    ,@IDROLUSUARIO INT
    ,@FECHAINICIO DATE
    ,@FECHAFIN DATE
    ,@USER INT
    ,@State INT OUTPUT
    ,@Message VARCHAR(255) OUTPUT
    ,@Id INT OUTPUT
    ,@CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

    --     IF @FECHAINICIO > @FECHAFIN
    --     BEGIN
    --     SET @State = - 1;
    --     SET @Message = 'La fecha de inicio no puede ser mayor a la fecha fin.';

    --     RETURN;
    -- END;

        IF NOT EXISTS (
                SELECT 1
    FROM Horario
    WHERE id = @IDHORARIO
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 1;
        SET @Message = 'El horario no existe o está inactivo.';

        RETURN;
    END;

        IF NOT EXISTS (
                SELECT 1
    FROM RolUsuario
    WHERE id = @IDROLUSUARIO
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 1;
        SET @Message = 'El rol de usuario no existe o está inactivo.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM HorarioUsuario
    WHERE rolUsuarioId_fk = @IDROLUSUARIO
        AND bEliminado = 0
        AND (
                        (@FECHAINICIO BETWEEN tFechaInicio AND tFechaFin)
        OR (@FECHAFIN BETWEEN tFechaInicio AND tFechaFin)
        OR (tFechaInicio BETWEEN @FECHAINICIO AND @FECHAFIN)
        OR (tFechaFin BETWEEN @FECHAINICIO AND @FECHAFIN)
                        )
                )
        BEGIN
        SET @State = - 1;
        SET @Message = 'Ya existe un horario asignado en ese rango de fechas para el usuario.';

        RETURN;
    END;
    --     IF EXISTS(
    --         SELECT 1
    -- FROM Vigencia
    -- WHERE bActivo = 1
    -- AND horarioDiasId_fk IN (SELECT horarioDiasId_fk
    --     FROM HorarioDias
    --     WHERE horarioId_fk = @IDHORARIO AND bEliminado = 0)
    --     AND bEliminado = 0
    --     AND ((
    --                 @FECHAINICIO < @FECHAFIN AND
    --                 (
    --                     @FECHAINICIO <= tFechaInicio
    --                     AND @FECHAFIN >= tfechaFin
    --                 )
    --             )
    --     ))
    --     BEGIN
    --     SET @State = -1;
    --     SET @Message = 'Debe de ingresar una fecha que este dentro de la vigencia del horario.';
    --     RETURN;
    -- END;

        INSERT INTO HorarioUsuario
        (
        horarioId_fk
        , rolUsuarioId_fk
        , tfechaInicio
        , tFechaFin
        , nCreatedBy
        )
    VALUES
        (
            @IDHORARIO
            , @IDROLUSUARIO
            , @FECHAINICIO
            , @FECHAFIN
            , @USER
            )

        SET @Id = SCOPE_IDENTITY()
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Inserción exitosa.';
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
END
GO
