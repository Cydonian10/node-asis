--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteTurnoModificado]
-- Fecha:  22-09-2025
-- Descripcion: Procedimiento para Eliminar de forma logica un registro de turno Modificado
-- Parámetros: 'ID', 'USUARIO'
-- bElimado: valor por defecto 0, al realizarse una eliminacion el valor cambia a 1 
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_DeleteTurnoModificado]
    @ID INT,
    @USUARIO INT OUTPUT,
    @State INT OUTPUT,
    @Message VARCHAR (250) OUTPUT,
    @CodeError INT OUTPUT
AS 
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
    IF NOT EXISTS (SELECT 1 
    FROM TurnoModificado
    WHERE id = @ID AND bEliminado = 0)
    BEGIN 
        SET @State = -1;
        SET @Message = 'Turno Modificado no encontrado'
        SET @CodeError = -1;
        RETURN;
    END 
    UPDATE TurnoModificado 
        SET bEliminado = 1,
            nUpdatedBy = @USUARIO,
            tUpdatedAt = GETDATE()
        WHERE id = @ID
        SET @State = 0;
        SET @Message = 'El turno modificado eliminado correctamente'
        SET @codeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END 
GO
