/*======================================================================================================
NOMBRE: [dbo].[usp_UnassignControlUnidad]
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Eliminar logicamente la asignacion activa de un control hacia una unidad. Libera la unidad
          para poder asignarle otro control.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnassignControlUnidad]
    @ControlId INT,
    @UnidadId INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 FROM ControlUnidad
            WHERE ControlId = @ControlId AND UnidadId = @UnidadId AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'La asignacion del control a la unidad no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE ControlUnidad
        SET Eliminado = 1,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE ControlId = @ControlId AND UnidadId = @UnidadId;

        SET @State = 1;
        SET @Message = 'Control desasignado de la unidad correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO