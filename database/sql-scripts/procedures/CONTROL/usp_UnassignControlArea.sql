/*======================================================================================================
NOMBRE: [dbo].[usp_UnassignControlArea]
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Eliminar logicamente la asignacion activa de un control hacia un area. Libera el area
          para poder asignarle otro control.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnassignControlArea]
    @ControlId INT,
    @AreaId INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 FROM ControlArea
            WHERE ControlId = @ControlId AND AreaId = @AreaId AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'La asignacion del control al area no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE ControlArea
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE ControlId = @ControlId AND AreaId = @AreaId;

        SET @State = 1;
        SET @Message = 'Control desasignado del area correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO