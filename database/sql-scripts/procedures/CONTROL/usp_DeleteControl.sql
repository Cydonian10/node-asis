/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControl]
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Aplicar eliminacion logica a un control. Rechaza la operacion si tiene asignaciones activas.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteControl]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM [Control] WHERE ControlId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El control no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM ControlArea WHERE ControlId = @ID AND Eliminado = 0
            UNION ALL
            SELECT 1 FROM ControlUnidad WHERE ControlId = @ID AND Eliminado = 0
            UNION ALL
            SELECT 1 FROM ControlUsuario WHERE ControlId = @ID AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar el control porque tiene asignaciones activas (area, unidad o usuario)';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE [Control]
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE ControlId = @ID;

        SET @State = 1;
        SET @Message = 'Control eliminado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO