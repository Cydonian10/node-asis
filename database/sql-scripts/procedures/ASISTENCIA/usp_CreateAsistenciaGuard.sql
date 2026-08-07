/*======================================================================================================
NOMBRE: [dbo].[usp_CreateAsistenciaGuard]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Crear una asistencia generada por un guard (Vacaciones/Licencia/Permiso/Justificado) o por
          Falta (sin marcas). Ambos estados apuntan al mismo estado y ResultadoAsistencia = ese guard.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateAsistenciaGuard]
    -- Parametros de entrada
    @UsuarioId INT,
    @Fecha DATE,
    @TurnoId INT,
    @GuardNombre VARCHAR(50),
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
        IF NOT EXISTS (
            SELECT 1 FROM EstadoAsistencia
            WHERE Nombre = @GuardNombre AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El estado de asistencia no existe: ' + @GuardNombre;
            SET @CodeError = -1;
            RETURN;
        END

        DECLARE @EstadoId INT;
        SELECT @EstadoId = EstadoAsistenciaId
        FROM EstadoAsistencia
        WHERE Nombre = @GuardNombre AND Eliminado = 0;

        INSERT INTO Asistencia (
            UsuarioId, Fecha, EstadoAsistenciaEntradaId, EstadoAsistenciaSalidaId,
            ResultadoAsistencia, HoraEntrada, HoraSalida,
            turnoEntrada, turnoId, turnoSalida,
            CreatedBy, UpdatedBy
        )
        VALUES (
            @UsuarioId, @Fecha, @EstadoId, @EstadoId,
            @GuardNombre, NULL, NULL,
            @turnoEntrada, @TurnoId, @turnoSalida,
            @USER, @USER
        );

        SET @Id = SCOPE_IDENTITY();

        SET @State = 1;
        SET @Message = 'Asistencia por ' + @GuardNombre + ' creada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
