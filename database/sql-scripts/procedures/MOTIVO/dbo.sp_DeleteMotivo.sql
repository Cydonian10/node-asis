--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteMotivo]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para Eliminar de forma logica un registro de Motivo
-- Parámetros: 'ID', 'USUARIO'
-- bElimado: valor por defecto 0, al realizarse una eliminacion el valor cambia a 1 
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_DeleteMotivo]
    @ID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS(SELECT 1
    FROM Motivo
    WHERE id = @ID)
    BEGIN
        SET @state = -1;
        SET @Message = 'Motivo no encontrado'
        SET @CodeError = -1;
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM Permiso
    WHERE motivoId_fk = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'se esta usando el motivo en un permiso'
        SET @CodeError = -1;
        RETURN;
    END
    
    IF EXISTS (SELECT 1
    FROM Licencia 
    WHERE motivoId_fk = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'El motivo se esta usado en una licencia'
        SET @CodeError = -1;
        RETURN;
    END

    IF EXISTS (SELECT 1
    FROM Justificacion 
    WHERE motivoId_fk = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'El motivo se esta usando en una Justificacion'
        SET @CodeError = -1;
        RETURN;
    END

    UPDATE Motivo 
        SET nUpdatedBy = @USUARIO,
            tUpdatedAt = GETDATE(),
            bEliminado = 1
        WHERE id = @ID

        SET @State = 0;
        SET @Message = 'eliminado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH 
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
