/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateHorario]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar los campos planos de un horario (ISNULL sobre la columna actual). Si @AreaId
          viene y cambia el area actual, marca Eliminado = 1 las asignaciones de usuarios que ya no
          pertenezcan al nuevo area.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateHorario]
    -- Parametros de entrada
    @ID INT,
    @Nombre VARCHAR(200) = NULL,
    @AreaId INT = NULL,
    @Extendido BIT = NULL,
    @Rotativo BIT = NULL,
    @Regular BIT = NULL,
    @HorasLaborales INT = NULL,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Horario WHERE HorarioId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El horario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF @AreaId IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM Area WHERE AreaId = @AreaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El area no existe';
            SET @CodeError = -1;
            RETURN;
        END

        DECLARE @AreaAnterior INT;
        SELECT @AreaAnterior = AreaId FROM Horario WHERE HorarioId = @ID;

        UPDATE Horario
        SET Nombre = ISNULL(@Nombre, Nombre),
            AreaId = ISNULL(@AreaId, AreaId),
            Extendido = ISNULL(@Extendido, Extendido),
            Rotativo = ISNULL(@Rotativo, Rotativo),
            Regular = ISNULL(@Regular, Regular),
            HorasLaborales = ISNULL(@HorasLaborales, HorasLaborales),
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE HorarioId = @ID;

        -- Si cambio el area, limpiar asignaciones cuyos usuarios ya no pertenezcan al nuevo area
        IF @AreaId IS NOT NULL AND @AreaId <> @AreaAnterior
        BEGIN
            UPDATE HA
            SET HA.Eliminado = 1,
                HA.UpdatedAt = GETDATE(),
                HA.UpdatedBy = @USER
            FROM HorarioAsignacion HA
            INNER JOIN Usuario U ON U.UsuarioId = HA.UsuarioId
            WHERE HA.HorarioId = @ID
                AND HA.Eliminado = 0
                AND NOT EXISTS (
                    SELECT 1 FROM UsuarioArea UA
                    WHERE UA.UsuarioId = U.UsuarioId AND UA.AreaId = @AreaId AND UA.Eliminado = 0
                );
        END

        SET @State = 1;
        SET @Message = 'Horario actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
