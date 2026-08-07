/*======================================================================================================
NOMBRE: [dbo].[usp_CreateVigencia]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Crear una vigencia sobre un HorarioDia. Se usa en horarios rotativos: define el rango de
          fechas en el que aplican los turnos de ese dia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateVigencia]
    -- Parametros de entrada
    @HorarioDiaId INT,
    @FechaInicio DATE,
    @FechaFin DATE = NULL,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM HorarioDia WHERE HorarioDiaId = @HorarioDiaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El dia del horario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF @FechaFin IS NOT NULL AND @FechaFin < @FechaInicio
        BEGIN
            SET @State = -1;
            SET @Message = 'FechaFin no puede ser anterior a FechaInicio';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO Vigencia (HorarioDiaId, FechaInicio, FechaFin, Eliminado, CreatedBy, UpdatedBy)
        VALUES (@HorarioDiaId, @FechaInicio, @FechaFin, 0, @USER, @USER);

        SET @Id = SCOPE_IDENTITY();

        SET @State = 1;
        SET @Message = 'Vigencia creada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
