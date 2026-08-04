--=================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertAsistenciaModificada]
-- Fecha:  26-09-2025
-- Descripcion: Procedimiento para actualizar un registro de asistencia modificada 
-- solo se perimita modificar el turno
--=================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_UpdateAsistenciaModificada]
    @USUARIO INT,
    @ID INT,
    @IDTURNO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM AsistenciaModificada 
    WHERE id = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'Asistencia modificada no valida'
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM AsistenciaModificada
    WHERE turnoModificadoId_fk = @IDTURNO AND id <> @ID)
    BEGIN 
        SET @State = -1;
        SET @Message = 'El turno ya fue ingresado en la asistencia modificada'
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM TurnoModificado
    WHERE id = @IDTURNO AND bEliminado = 0 )
    BEGIN 
        SET @State = -1;
        SET @Message = 'turno mofidicado no valido'
        RETURN;
    END
    
    UPDATE AsistenciaModificada
        SET turnoModificadoId_fk = @IDTURNO,
            nUpdatedBy =COALESCE(nUpdatedBy, @USUARIO),
            tUpdatedAt = GETDATE()
        WHERE id = @ID
            SET @State = 0;
            SET @Message = 'Asistencia modificada actualizada correctamente'
            SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO