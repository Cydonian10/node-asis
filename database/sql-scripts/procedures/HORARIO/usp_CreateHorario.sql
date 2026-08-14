/*======================================================================================================
NOMBRE: [dbo].[usp_CreateHorario]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Crear un horario plano (nombre, area, flags, horas). Los dias/turnos/grupos de vigencia/
          asignaciones se crean en la misma transaccion Node.js con los SPs CreateHorarioDia/
          CreateTurno/CreateVigenciaGrupo/AsignarUsuariosHorario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateHorario]
    -- Parametros de entrada
    @Nombre VARCHAR(200),
    @AreaId INT,
    @Extendido BIT = 0,
    @Rotativo BIT = 0,
    @Regular BIT = 1,
    @HorasLaborales INT = 8,
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
        IF NOT EXISTS (SELECT 1 FROM Area WHERE AreaId = @AreaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El area no existe';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO Horario (Nombre, AreaId, Extendido, Rotativo, Regular, HorasLaborales, Eliminado, CreatedBy, UpdatedBy)
        VALUES (@Nombre, @AreaId, @Extendido, @Rotativo, @Regular, @HorasLaborales, 0, @USER, @USER);

        SET @Id = SCOPE_IDENTITY();

        SET @State = 1;
        SET @Message = 'Horario creado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
