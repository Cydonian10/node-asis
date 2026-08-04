/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteRol]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar un Rol

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteRol]
    @ROL_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY

    IF EXISTS ( SELECT 1 FROM RolControl WHERE rolId_fk = @ROL_ID and bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: el está vinculada a [Control].'
            SET @CodeError = -1;
        RETURN;
    END

        
    IF EXISTS ( SELECT 1 FROM RolUsuario WHERE rolId_fk = @ROL_ID and bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: la unidad está vinculada a [Usuario].'
            SET @CodeError = -1;
        RETURN;
    END

       
    IF NOT EXISTS ( SELECT 1 FROM Rol WHERE id = @ROL_ID AND bEliminado = 0 )
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro no existe o ya ha sido eliminado.';
            SET @CodeError = -1;
        RETURN;
    END

    -- Eliminación lógica
    UPDATE Rol
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = SYSDATETIME()
        WHERE id = @ROL_ID;

    SET @State = 1;
    SET @Message = 'Rol eliminado correctamente';
    SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO


