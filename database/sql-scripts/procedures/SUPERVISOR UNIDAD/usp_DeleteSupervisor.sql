--==============================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_DeleteSupervisor]
-- Fecha: 06-10-2025
-- Descripcion: Procedimiento para eliminar de forma logica un registro de la tabla Supervisor
-- Parámetros: 
-- @USUARIO_ID: id de un registro de la tabla Sync_Usuario (int)
-- @UNIDAD_ID: id de un registro de la tabla Unidad (int)
-- @USUARIO: Id del usuario que realiza la eliminacion (int)
--============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteSupervisor]
    @UNIDAD_ID INT,
    @USUARIO_ID INT,
    @USUARIO INT,
    @Message VARCHAR(250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY
  

    DELETE FROM Supervisor
        WHERE usuarioId_pk = @USUARIO_ID AND unidadId_pk = @UNIDAD_ID
        SET @State = 1
        SET @Message = 'Eliminado correctamente'
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO


