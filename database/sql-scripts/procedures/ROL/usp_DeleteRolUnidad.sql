/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteRolUnidad]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Soft-delete (Eliminado = 1) de un rol-en-unidad. Valida restricciones antes: no debe
          haber filas no eliminadas en UsuarioRol que referencien RolUnidadId. Si las hay, error.
          Si no, marca Eliminado = 1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteRolUnidad]
    -- Parametros de entrada
    @ID INT,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM RolUnidad WHERE RolUnidadId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El rol de la unidad no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM UsuarioRol WHERE RolUnidadId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar el rol de la unidad porque tiene usuarios asignados (UsuarioRol)';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE RolUnidad
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE RolUnidadId = @ID;

        SET @State = 1;
        SET @Message = 'Rol de la unidad eliminado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
