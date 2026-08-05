/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteArea]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Soft-delete (Eliminado = 1) de un area. Valida restricciones antes: no debe haber Usuarios
          no eliminados que referencien AreaId, ni filas en Horario que referencien AreaId (Horario
          no tiene flag Eliminado, cuentan todas). Si hay alguna, responde error (SPEC 04).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteArea]
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
        IF NOT EXISTS (SELECT 1 FROM Area WHERE AreaId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El area no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Usuario WHERE AreaId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar el area porque tiene usuarios asignados (Usuario)';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Horario WHERE AreaId = @ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar el area porque tiene horarios asociados (Horario)';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Area
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE AreaId = @ID;

        SET @State = 1;
        SET @Message = 'Area eliminada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
