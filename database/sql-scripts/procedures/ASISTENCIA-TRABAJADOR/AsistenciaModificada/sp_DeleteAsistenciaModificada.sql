--=================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre:  [dbo].[sp_DeleteAsistenciaModificada]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para eliminar un registro de asistencia modificada 
--=================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_DeleteAsistenciaModificada]
    @ID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT, 
    @CodeError  INT OUTPUT

AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM AsistenciaModificada 
    WHERE id = @ID )
    BEGIN
        SET @State = -1;
        SET @Message = 'no se encontro la asistencia Modificada'
        SET @CodeError = -1;
        RETURN;
    END 
    UPDATE AsistenciaModificada 
        SET bEliminado = 1,
            tUpdatedAt = GETDATE(),
            nUpdatedBy = @USUARIO
        WHERE id = @ID
        SET @State = 0;
        SET @Message = 'Asistencia eliminado Correctamente'
        SET @codeError = 0
    END TRY 
    BEGIN CATCH
        SET @state = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

            