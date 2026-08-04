
--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteHorarioDias]
-- Fecha:  17-09-2025
-- Descripcion: El procedimiento elimina un registro de horariodia
-- si el hoarioDia se esta usando en otras tablas no se podra eliminar
--=========================================================================================
CREATE OR ALTER  PROCEDURE [dbo].[sp_DeleteHorarioDias]
    @ID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT,
    @Message VARCHAR (250) OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY 
    IF NOT EXISTS (SELECT 1
    FROM HorarioDias
    WHERE Id = @ID AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'Horario-Dia no encontrado'
        SET @CodeError = -1;
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM TurnoExtendido
    WHERE HorarioDiasId_fk = @ID AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'Horario dia en uso dentro de Turno extendido'
        SET @CodeError = -1;
        RETURN;
    END
    IF EXISTS ( SELECT 1
    FROM TurnoRegular
    WHERE HorarioDiasID_fk = @ID AND bEliminado = 0)
    BEGIN
        SET @State = -1
        SET @Message = 'Horario dia en uso dentro de un Turno Regular'
        SET @CodeError = -1;
        RETURN;
    END
     -- Si existen vigencia relacionado, marcarlos como eliminados
        IF EXISTS (
            SELECT 1
    FROM vigencia
    WHERE HorarioDiasId_fk = @ID
        )
        BEGIN
        UPDATE vigencia
            SET bEliminado = 1
            WHERE HorarioDiasId_fk = @ID;
    END


    UPDATE HorarioDias
        SET bEliminado = 1
        WHERE id = @ID
        SET @State = 0;
        SET @Message = 'Horario-Dia eliminado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
