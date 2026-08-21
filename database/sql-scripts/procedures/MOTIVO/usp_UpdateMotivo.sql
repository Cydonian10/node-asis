/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateMotivo]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Actuliza un motivo

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -    -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateMotivo]
    @ID INT,
    @Nombre VARCHAR(100) = NULL,
    @Descripcion VARCHAR(255) = NULL,
    @DocumentoRequerido BIT = NULL,
    @ActualizarNombre BIT,
    @ActualizarDescripcion BIT,
    @ActualizarDocumentoRequerido BIT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Motivo WHERE MotivoId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El motivo no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF @ActualizarNombre = 1
        BEGIN
            SET @Nombre = LTRIM(RTRIM(@Nombre));

            IF EXISTS (
                SELECT 1
                FROM Motivo
                WHERE Nombre = @Nombre
                  AND MotivoId <> @ID
                  AND Eliminado = 0
            )
            BEGIN
                SET @State = -1;
                SET @Message = 'Ya existe un motivo activo con ese nombre';
                SET @CodeError = -1;
                RETURN;
            END
        END

        UPDATE Motivo
        SET Nombre = CASE WHEN @ActualizarNombre = 1 THEN @Nombre ELSE Nombre END,
            Descripcion = CASE WHEN @ActualizarDescripcion = 1 THEN @Descripcion ELSE Descripcion END,
            DocumentoRequerido = CASE WHEN @ActualizarDocumentoRequerido = 1 THEN @DocumentoRequerido ELSE DocumentoRequerido END,
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE MotivoId = @ID
          AND Eliminado = 0;

        SET @State = 1;
        SET @Message = 'Motivo actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
