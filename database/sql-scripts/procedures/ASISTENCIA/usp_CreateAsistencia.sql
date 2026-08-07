/*======================================================================================================
NOMBRE: [dbo].[usp_CreateAsistencia]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Insertar una asistencia con snapshots (turno, vigencia) y estados de entrada/salida.
          Computa ResultadoAsistencia si no viene: igual -> copia el nombre; distintos -> "A - B";
          ambos NULL -> 'Falta'.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateAsistencia]
    -- Parametros de entrada
    @UsuarioId INT,
    @Fecha DATE,
    @TurnoId INT,
    @HoraEntrada DATETIME2 = NULL,
    @EstadoEntradaId INT = NULL,
    @EstadoSalidaId INT = NULL,
    @ResultadoAsistencia VARCHAR(50) = NULL,
    @ControlId INT = NULL,
    @vigenciaInicio DATE = NULL,
    @vigenciaFin DATE = NULL,
    @turnoEntrada TIME = NULL,
    @turnoSalida TIME = NULL,
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
        DECLARE @NombreEntrada VARCHAR(50);
        DECLARE @NombreSalida VARCHAR(50);

        SELECT @NombreEntrada = Nombre FROM EstadoAsistencia WHERE EstadoAsistenciaId = @EstadoEntradaId;
        SELECT @NombreSalida = Nombre FROM EstadoAsistencia WHERE EstadoAsistenciaId = @EstadoSalidaId;

        IF @ResultadoAsistencia IS NULL
        BEGIN
            IF @EstadoEntradaId IS NULL AND @EstadoSalidaId IS NULL
            BEGIN
                SET @ResultadoAsistencia = 'Falta';
            END
            ELSE IF @EstadoEntradaId = @EstadoSalidaId
            BEGIN
                SET @ResultadoAsistencia = @NombreEntrada;
            END
            ELSE
            BEGIN
                SET @ResultadoAsistencia =
                    ISNULL(@NombreEntrada, '')
                    + CASE WHEN @NombreEntrada IS NOT NULL AND @NombreSalida IS NOT NULL THEN ' - ' ELSE '' END
                    + ISNULL(@NombreSalida, '');
            END
        END

        INSERT INTO Asistencia (
            UsuarioId, Fecha, EstadoAsistenciaEntradaId, EstadoAsistenciaSalidaId,
            ResultadoAsistencia, ControlId, HoraEntrada, HoraSalida,
            vigenciaInicio, vigenciaFin, turnoEntrada, turnoId, turnoSalida,
            CreatedBy, UpdatedBy
        )
        VALUES (
            @UsuarioId, @Fecha, @EstadoEntradaId, @EstadoSalidaId,
            @ResultadoAsistencia, @ControlId, @HoraEntrada, NULL,
            @vigenciaInicio, @vigenciaFin, @turnoEntrada, @TurnoId, @turnoSalida,
            @USER, @USER
        );

        SET @Id = SCOPE_IDENTITY();

        SET @State = 1;
        SET @Message = 'Asistencia creada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
