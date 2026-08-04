/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateHorarioUsuario]
FECHA: 03-10-2024
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Actualizar un registro en la tabla HorarioUsuario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE dbo.usp_UpdateHorarioUsuario
    @ID INT,
    @FECHAINICIO DATE = NULL,
    @FECHAFIN DATE = NULL,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET @CodeError = 0;
    BEGIN TRY
        DECLARE @AffectedRows INT;

        IF @FECHAINICIO > @FECHAFIN
        BEGIN
        SET @State = -1;
        SET @Message = 'La fecha de inicio no puede ser mayor a la fecha fin.';
        RETURN;
    END;
    --     IF NOT EXISTS(
    --         SELECT 1
    -- FROM Vigencia
    -- WHERE horarioDiasId_fk IN(SELECT horarioDiasId_fk
    --     FROM HorarioDias
    --     WHERE horarioId_fk = @ID AND bEliminado = 0)
    --     AND bActivo = 1
    --     AND bEliminado = 0
    --     AND (
    --          @FECHAINICIO >= tFechaInicio
    --     AND @FECHAFIN <= tfechaFin
    --     )
        
    --     )
    --     BEGIN
    --     SET @State = -1;
    --     SET @Message = 'El rango de fechas ingresado debe de estar dentro de la vigencia del horario.';
    --     RETURN;
    -- END;

        IF NOT EXISTS (
            SELECT 1
    FROM dbo.HorarioUsuario
    WHERE id = @ID
        AND bEliminado = 0
        )
        BEGIN
        SET @State = -1;
        SET @Message = 'El registro de HorarioUsuario no existe o está inactivo.';
        RETURN;
    END;

        UPDATE dbo.HorarioUsuario
        SET 
            tfechaInicio = COALESCE(@FECHAINICIO, tfechaInicio),
            tFechaFin = COALESCE(@FECHAFIN, tFechaFin),
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID
        AND bEliminado = 0;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Actualización exitosa.';
    END
        ELSE
        BEGIN
        SET @State = -1;
        SET @Message = 'No se realizó ninguna actualización.';
    END
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

