/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateVigenciaGrupo]
FECHA: 17-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar las fechas y el orden de un grupo de vigencia (ISNULL sobre la columna actual).
          Los dias y turnos del grupo no se tocan; solo se actualiza el rango de fechas/orden.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateVigenciaGrupo]
    @ID INT,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @Orden INT = NULL,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM VigenciaGrupo WHERE VigenciaGrupoId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El grupo de vigencia no existe';
            SET @CodeError = -1;
            RETURN;
        END

        DECLARE @FechaInicioActual DATE;
        SELECT @FechaInicioActual = FechaInicio FROM VigenciaGrupo WHERE VigenciaGrupoId = @ID;

        IF ISNULL(@FechaFin, (SELECT FechaFin FROM VigenciaGrupo WHERE VigenciaGrupoId = @ID)) IS NOT NULL
           AND ISNULL(@FechaFin, (SELECT FechaFin FROM VigenciaGrupo WHERE VigenciaGrupoId = @ID)) < ISNULL(@FechaInicio, @FechaInicioActual)
        BEGIN
            SET @State = -1;
            SET @Message = 'FechaFin no puede ser anterior a FechaInicio';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE VigenciaGrupo
        SET FechaInicio = ISNULL(@FechaInicio, FechaInicio),
            FechaFin = ISNULL(@FechaFin, FechaFin),
            Orden = ISNULL(@Orden, Orden),
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE VigenciaGrupoId = @ID;

        SET @State = 1;
        SET @Message = 'Grupo de vigencia actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO