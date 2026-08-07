/*======================================================================================================
NOMBRE: [dbo].[usp_CreateTurno]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Crear un turno dentro de un HorarioDia. Si Extendido = 1, HoraFin pasa la medianoche
          (dia conectado).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateTurno]
    -- Parametros de entrada
    @HorarioDiaId INT,
    @HoraInicio TIME,
    @HoraFin TIME,
    @Extendido BIT = 0,
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

        INSERT INTO Turno (HorarioDiaId, HoraInicio, HoraFin, Extendido, Eliminado, CreatedBy, UpdatedBy)
        VALUES (@HorarioDiaId, @HoraInicio, @HoraFin, @Extendido, 0, @USER, @USER);

        SET @Id = SCOPE_IDENTITY();

        SET @State = 1;
        SET @Message = 'Turno creado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
