--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_UpdateTurnoModificado]
-- Fecha:  22-09-2025
-- Descripcion: Procedimiento para actualizar datos de un registros de turno Modificado 
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_UpdateTurnoModificado]
    @ID INT,
    @IDROLUSUARIO INT = NULL,
    @USUARIO INT,
    @TIPO INT,
    @HORA TIME(7),
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT
    
AS
BEGIN
    SET NOCOUNT ,
    XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM TurnoModificado
    WHERE id = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'No se encontro el turno modificado'
        SET @CodeError = -1;
        RETURN;
    END
    UPDATE TurnoModificado
    SET tHora = @HORA,
        bTipo = COALESCE(@TIPO, bTipo),
        rolUsuarioId_fk = COALESCE(@IDROLUSUARIO, rolUsuarioId_fk),
        nUpdatedBy = @USUARIO,
        tUpdatedAt = GETDATE()
    WHERE 
     id = @ID
        SET @State = -1;
        SET @Message = 'Tunno Modificado actualizado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO