/*======================================================================================================
NOMBRE: [dbo].[usp_CreateVigenciaGrupo]
FECHA: 14-08-2026
AUTOR: Gabriel
OBJETIVO: Crear un grupo de vigencia para un horario rotativo. Define un rango de fechas que agrupa
          sus propios dias y turnos (un mismo DiaId puede repetirse en varios grupos con turnos
          distintos). Se crea antes de los HorarioDia del grupo.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateVigenciaGrupo]
    -- Parametros de entrada
    @HorarioId INT,
    @FechaInicio DATE,
    @FechaFin DATE = NULL,
    @Orden INT = 0,
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
        IF NOT EXISTS (SELECT 1 FROM Horario WHERE HorarioId = @HorarioId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El horario no existe';
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

        INSERT INTO VigenciaGrupo (HorarioId, FechaInicio, FechaFin, Orden, Eliminado, CreatedBy, UpdatedBy)
        VALUES (@HorarioId, @FechaInicio, @FechaFin, @Orden, 0, @USER, @USER);

        SET @Id = SCOPE_IDENTITY();

        SET @State = 1;
        SET @Message = 'Grupo de vigencia creado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
