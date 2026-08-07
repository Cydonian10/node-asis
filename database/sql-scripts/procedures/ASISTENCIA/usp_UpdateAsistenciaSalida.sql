/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateAsistenciaSalida]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar la salida de una asistencia (HoraSalida + estado de salida + resultado).
          Recomputa ResultadoAsistencia combinando entrada + salida.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateAsistenciaSalida]
    -- Parametros de entrada
    @AsistenciaId INT,
    @HoraSalida DATETIME2,
    @EstadoSalidaId INT = NULL,
    @ResultadoAsistencia VARCHAR(50) = NULL,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Asistencia WHERE AsistenciaId = @AsistenciaId)
        BEGIN
            SET @State = -1;
            SET @Message = 'La asistencia no existe';
            SET @CodeError = -1;
            RETURN;
        END

        DECLARE @EstadoEntradaId INT;
        DECLARE @NombreEntrada VARCHAR(50);
        DECLARE @NombreSalida VARCHAR(50);

        SELECT @EstadoEntradaId = EstadoAsistenciaEntradaId
        FROM Asistencia
        WHERE AsistenciaId = @AsistenciaId;

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

        UPDATE Asistencia
        SET HoraSalida = @HoraSalida,
            EstadoAsistenciaSalidaId = @EstadoSalidaId,
            ResultadoAsistencia = @ResultadoAsistencia,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE AsistenciaId = @AsistenciaId;

        SET @State = 1;
        SET @Message = 'Salida actualizada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
