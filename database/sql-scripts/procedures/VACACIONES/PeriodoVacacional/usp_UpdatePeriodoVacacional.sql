/*======================================================================================================
NOMBRE: [dbo].[usp_UpdatePeriodoVacacional]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Actualizar datos de control vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_UpdatePeriodoVacacional] @ID INT
    , @FECHAINICIO DATE = NULL
    , @FECHAFIN DATE = NULL
    , @DIASCONSUMIDOS INT = NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT
        , @fechaInicioNueva DATE
        , @fechaFinNueva DATE
        , @diasConsumidosNueva INT
        , @controlVacacionalId INT
        , @fechaInicioActual DATE
        , @fechaFinActual DATE
        , @diasConsumidosActual INT

    BEGIN TRY
        -- Obtener valores actuales del registro
        SELECT @fechaInicioActual = fechaInicio
            , @fechaFinActual = fechaFin
            , @diasConsumidosActual = nDiasConsumidos
            , @controlVacacionalId = controlVacacionalId_fk
        FROM PeriodoVacacional
        WHERE Id = @ID;

        SET @fechaInicioNueva = COALESCE(NULLIF(@FECHAINICIO, ''), @fechaInicioActual)
        SET @fechaFinNueva = COALESCE(NULLIF(@FECHAFIN, ''), @fechaFinActual)
        SET @diasConsumidosNueva = COALESCE(@DIASCONSUMIDOS, @diasConsumidosActual)

        IF NOT EXISTS (
                SELECT 1
                FROM PeriodoVacacional
                WHERE bEliminado = 0
                    AND Id = @ID
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El periodo vacacional no existe o fue eliminado';

            RETURN
        END

        -- Validar orden de fechas
        IF (@fechaInicioNueva >= @fechaFinNueva)
        BEGIN
            SET @State = - 1;
            SET @Message = 'La fecha de inicio debe ser menor a la fecha fin.';

            RETURN;
        END;

        -- Validar que dias consumidos sea positivo
        IF (
                @DIASCONSUMIDOS IS NOT NULL
                AND @DIASCONSUMIDOS <= 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'Los días consumidos deben ser mayores a cero.';

            RETURN;
        END;

        

        -- Validar solapamiento con otros registros
        IF EXISTS (
                SELECT 1
                FROM PeriodoVacacional
                WHERE controlVacacionalId_fk = @controlVacacionalId
                    AND bEliminado = 0
                    AND Id <> @ID
                    AND @fechaInicioNueva <= fechaFin
                    AND @fechaFinNueva >= fechaInicio
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El periodo vacacional se sobrepone con otro ya registrado.';

            RETURN;
        END;

        -- Validar que no se excedan los días disponibles
        DECLARE @DiasDisponibles INT
            , @DiasYaConsumidos INT;

        SELECT @DiasDisponibles = nDiasDisponibles
        FROM ControlVacaciones
        WHERE id = @controlVacacionalId;

        SELECT @DiasYaConsumidos = ISNULL(SUM(nDiasConsumidos), 0)
        FROM PeriodoVacacional
        WHERE controlVacacionalId_fk = @controlVacacionalId
            AND bEliminado = 0;

        IF (@DiasYaConsumidos + @DIASCONSUMIDOS) > @DiasDisponibles
        BEGIN
            SET @State = - 1;
            SET @Message = 'Los días consumidos exceden los días disponibles.';

            RETURN;
        END;

        UPDATE PeriodoVacacional
        SET fechaInicio = @fechaInicioNueva
            , fechaFin = @fechaFinNueva
            , nDiasConsumidos = @diasConsumidosNueva
            , nUpdatedBy = @USER
            , tUpdateAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER()
    END CATCH
END
GO
