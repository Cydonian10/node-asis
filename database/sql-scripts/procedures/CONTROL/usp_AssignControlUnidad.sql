/*======================================================================================================
NOMBRE: [dbo].[usp_AssignControlUnidad]
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Asignar un control activo a una unidad activa. Solo se permite una asignacion activa por unidad.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_AssignControlUnidad]
    @ControlId INT,
    @UnidadId INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM [Control] WHERE ControlId = @ControlId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El control no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Unidad WHERE UnidadId = @UnidadId)
        BEGIN
            SET @State = -1;
            SET @Message = 'La unidad no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM ControlUnidad WHERE UnidadId = @UnidadId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'La unidad ya tiene un control asignado';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO ControlUnidad (ControlId, UnidadId, CreatedBy, UpdatedBy)
        VALUES (@ControlId, @UnidadId, @USER, @USER);

        SET @Id = CONVERT(INT, SCOPE_IDENTITY());
        SET @State = 1;
        SET @Message = 'Control asignado a la unidad correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO