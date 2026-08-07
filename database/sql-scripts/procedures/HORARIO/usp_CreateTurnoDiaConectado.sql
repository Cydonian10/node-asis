/*======================================================================================================
NOMBRE: [dbo].[usp_CreateTurnoDiaConectado]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Crear el dia conectado (conexion a un Dia via SalidaTurnoDia) de un turno. Solo se permite
          si el turno existe, no esta eliminado y tiene Extendido = 1 (HoraFin pasa la medianoche).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateTurnoDiaConectado]
    -- Parametros de entrada
    @TurnoId INT,
    @DiaId INT,
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
        IF NOT EXISTS (SELECT 1 FROM Turno WHERE TurnoId = @TurnoId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Turno WHERE TurnoId = @TurnoId AND Extendido = 1)
        BEGIN
            SET @State = -1;
            SET @Message = 'Solo un turno extendido puede tener dia conectado';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Dia WHERE DiaId = @DiaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El dia conectado no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM SalidaTurnoDia WHERE TurnoId = @TurnoId AND DiaId = @DiaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno ya tiene ese dia conectado';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO SalidaTurnoDia (TurnoId, DiaId, Eliminado, CreatedBy, UpdatedBy)
        VALUES (@TurnoId, @DiaId, 0, @USER, @USER);

        SET @Id = SCOPE_IDENTITY();

        SET @State = 1;
        SET @Message = 'Dia conectado creado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
