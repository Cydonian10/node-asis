/*======================================================================================================
NOMBRE: [dbo].[usp_CreateHorarioDia]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Crear un dia ligado a un horario (HorarioDia). Valida que el horario y el dia existan.
          En horarios rotativos un mismo DiaId puede repetirse (una fila por grupo de vigencia).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  1  14-08-2026  Gabriel    Parametro VigenciaGrupoId (grupo de vigencia del dia, NULL si no rotativo).
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateHorarioDia]
    -- Parametros de entrada
    @HorarioId INT,
    @DiaId INT,
    @VigenciaGrupoId INT = NULL,
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

        IF NOT EXISTS (SELECT 1 FROM Dia WHERE DiaId = @DiaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El dia no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF @VigenciaGrupoId IS NOT NULL
            AND NOT EXISTS (
                SELECT 1 FROM VigenciaGrupo
                WHERE VigenciaGrupoId = @VigenciaGrupoId AND HorarioId = @HorarioId AND Eliminado = 0
            )
        BEGIN
            SET @State = -1;
            SET @Message = 'El grupo de vigencia no existe o no pertenece al horario';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO HorarioDia (HorarioId, VigenciaGrupoId, DiaId, Orden, Eliminado, CreatedBy, UpdatedBy)
        VALUES (@HorarioId, @VigenciaGrupoId, @DiaId, @Orden, 0, @USER, @USER);

        SET @Id = SCOPE_IDENTITY();

        SET @State = 1;
        SET @Message = 'Dia agregado al horario correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
