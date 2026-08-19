/*======================================================================================================
NOMBRE: [dbo].[usp_AssignControlArea]
FECHA: 19-08-2026
AUTOR: Gabriel
OBJETIVO: Asignar un control activo a un area activa. Solo se permite una asignacion activa por area.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_AssignControlArea]
    @ControlId INT,
    @AreaId INT,
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

        IF NOT EXISTS (SELECT 1 FROM Area WHERE AreaId = @AreaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El area no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM ControlArea WHERE AreaId = @AreaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El area ya tiene un control asignado';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO ControlArea (ControlId, AreaId, CreatedBy, UpdatedBy)
        VALUES (@ControlId, @AreaId, @USER, @USER);

        SET @Id = CONVERT(INT, SCOPE_IDENTITY());
        SET @State = 1;
        SET @Message = 'Control asignado al area correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO