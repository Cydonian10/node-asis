/*======================================================================================================
NOMBRE: [dbo].[usp_CreateMarcaBiometrico]
FECHA: 18-08-2026
AUTOR: Gabriel
OBJETIVO: Crear una marca de biometrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateMarcaBiometrico]
    @Nombre VARCHAR(30),
    @TipoDB VARCHAR(20),
    @Detalle VARCHAR(50),
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM MarcaBiometrico WHERE Nombre = @Nombre)
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una marca de biometrico con ese nombre';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO MarcaBiometrico (Nombre, TipoDB, Detalle, CreatedBy, UpdatedBy)
        VALUES (@Nombre, @TipoDB, @Detalle, @USER, @USER);

        SET @Id = CONVERT(INT, SCOPE_IDENTITY());
        SET @State = 1;
        SET @Message = 'Marca de biometrico creada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
