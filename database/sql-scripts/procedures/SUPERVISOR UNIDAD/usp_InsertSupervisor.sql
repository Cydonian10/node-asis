--===================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_InsertSupervisor]
-- Fecha: 06-10-2025
-- Descripcion: Procedimiento para crear un nuevo registro en la tabla Supervisor
-- Parámetros: 
-- @USUARIO_ID: id de un registro de la tabla Sync_Usuario (int)
-- @UNIDAD_ID: id de un registro de la tabla Unidad (int)
-- @USUARIO: Id del usuario que realiza el registro (int)
--===================================================================================
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertSupervisor]
    @USUARIO_ID INT,
    @UNIDAD_ID INT,
    @USUARIO INT,
    @Message VARCHAR(250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM Sync_Usuario
    WHERE id = @USUARIO_ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'El id de Usuario no es Valido'
        SET @CodeError = -1;
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM Unidad
    WHERE id = @UNIDAD_ID AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'el id de la unidad no es valido o el registro fue eliminado'
        RETURN;
    END

    INSERT INTO Supervisor
        (usuarioId_pk, unidadId_pk, nCreatedBy, tCreatedAt)
    VALUES(@USUARIO_ID, @UNIDAD_ID, @USUARIO, GETDATE());
        SET  @Message = 'El registro de Supervisor fue creado correctamente'
        SET  @codeError = 0;
        SET  @State = 1;
    END TRY
    BEGIN CATCH
        SET @Message = ERROR_MESSAGE();
        SET @codeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO
