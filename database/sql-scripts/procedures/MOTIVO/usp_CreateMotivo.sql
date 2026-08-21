/*======================================================================================================
NOMBRE: [dbo].[usp_CreateMotivo]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Crear un motivo.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -    -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateMotivo]
    @Nombre VARCHAR(100),
    @Descripcion VARCHAR(255) = NULL,
    @DocumentoRequerido BIT = 0,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        SET @Nombre = LTRIM(RTRIM(@Nombre));

        IF EXISTS (SELECT 1 FROM Motivo WHERE Nombre = @Nombre AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe un motivo activo con ese nombre';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO Motivo (Nombre, Descripcion, DocumentoRequerido, CreatedBy, UpdatedBy)
        VALUES (@Nombre, @Descripcion, ISNULL(@DocumentoRequerido, 0), @USER, @USER);

        SET @Id = CONVERT(INT, SCOPE_IDENTITY());
        SET @State = 1;
        SET @Message = 'Motivo creado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
