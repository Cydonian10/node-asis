/*======================================================================================================
NOMBRE: [dbo].[usp_InsertPeriodoVacacional]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar periodo vacacional

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_InsertPeriodoVacacional]
    @IDCONTROLVACACIONAL INT
    , @FECHAINICIO DATE
    , @FECHAFIN DATE
    , @DIASCONSUMIDOS INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        -- Validar que no vengan vacíos o nulos
        IF (@FECHAINICIO IS NULL OR @FECHAINICIO = '')
        BEGIN
            SET @State = - 1;
            SET @Message = 'La fecha de inicio no es correcta.';

            RETURN;
        END;

        IF (@FECHAFIN IS NULL OR @FECHAFIN = '')
        BEGIN
             SET @State = - 1;
            SET @Message = 'La fecha de fin no es correcta.';

            RETURN;
        END;

        -- Validar que dias consumidos sea positivo
        IF (@DIASCONSUMIDOS IS NULL AND @DIASCONSUMIDOS <= 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Los días consumidos deben ser mayores a cero.';
            RETURN;
        END;

        -- Validar orden de fechas
        IF (@FECHAINICIO >= @FECHAFIN)
        BEGIN
            SET @State = - 1;
            SET @Message = 'La fecha de inicio debe ser menor a la fecha fin.';

            RETURN;
        END;

        -- Validar sobreposicion con otros periodos
        IF EXISTS (
                SELECT 1
                FROM PeriodoVacacional
                WHERE controlVacacionalId_fk = @IDCONTROLVACACIONAL
                    AND bEliminado = 0
                    AND (
                        (@FECHAINICIO BETWEEN fechaInicio AND fechaFin)
                        OR (@FECHAFIN BETWEEN fechaInicio AND fechaFin)
                        OR (fechaInicio BETWEEN @FECHAINICIO AND @FECHAFIN)
                        OR (fechaFin BETWEEN @FECHAINICIO AND @FECHAFIN)
                        )
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El periodo vacacional se sobrepone con otro existente.';

            RETURN;
        END;

        -- Validar duplicado exacto
        IF EXISTS (
                SELECT 1
                FROM PeriodoVacacional
                WHERE controlVacacionalId_fk = @IDCONTROLVACACIONAL
                    AND fechaInicio = @FECHAINICIO
                    AND fechaFin = @FECHAFIN
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El periodo vacacional ya existe.';

            RETURN;
        END;

        -- Validar que no se excedan los días disponibles
        DECLARE @DiasDisponibles INT
            , @DiasYaConsumidos INT;

        SELECT @DiasDisponibles = nDiasDisponibles
        FROM ControlVacaciones
        WHERE id = @IDCONTROLVACACIONAL;

        SELECT @DiasYaConsumidos = ISNULL(SUM(nDiasConsumidos), 0)
        FROM PeriodoVacacional
        WHERE controlVacacionalId_fk = @IDCONTROLVACACIONAL
            AND bEliminado = 0;

        IF (@DiasYaConsumidos + @DIASCONSUMIDOS) > @DiasDisponibles
        BEGIN
            SET @State = - 1;
            SET @Message = 'Los días consumidos exceden los días disponibles.';

            RETURN;
        END;

        INSERT INTO PeriodoVacacional (
            controlVacacionalId_fk
            , fechaInicio
            , fechaFin
            , nDiasConsumidos
            , nCreatedBy
            )
        VALUES (
            @IDCONTROLVACACIONAL
            , @FECHAINICIO
            , @FECHAFIN
            , @DIASCONSUMIDOS
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
