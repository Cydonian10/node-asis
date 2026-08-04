--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_UpdateMotivo]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para actualizar un registro de Motivo
-- Parámetros: 'ID', 'NOMBRE', 'DETALLE', 'DOCUMEMTO','USUARIO'
-- DOCUMNETO: estado que determina si el motivo tiene documento (valor por defecto 0)
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_UpdateMotivo]
    @ID INT, 
    @NOMBRE VARCHAR(50),
    @DETALLE VARCHAR(250),
    @DOCUMENTO BIT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT, 
    XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM Motivo
    WHERE id = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'Motivo no encontrado'
        SET @codeError = -1;
        RETURN;
    END
    BEGIN
    IF @NOMBRE IS NOT NULL
    BEGIN
        SET @NOMBRE = LTRIM(RTRIM(@NOMBRE));
        IF @NOMBRE = ''
        BEGIN 
            SET @Message = 'no se permite espacios en blanco en el nombre'
            SET @CodeError = -1;
            RETURN;
        END
    END
    IF EXISTS (SELECT 1
    FROM Motivo 
    WHERE nombre = @NOMBRE AND id <> @ID)
    BEGIN
        SET @State = -1
        SET @Message = 'ya existe un motivo con este nombre'
        SET @CodeError = -1;
        RETURN;
    END
    IF @DETALLE IS NULL AND @NOMBRE IS NULL AND @DOCUMENTO IS NULL
    BEGIN 
        SET @State = -1;
        SET @Message = 'al menos tiene que rellenar un campo'
        SET @CodeError =-1;
        RETURN
    END
    UPDATE Motivo
    SET nombre =  COALESCE(@NOMBRE, nombre),
        detalle = COALESCE(@DETALLE, detalle),
        bDocumento = COALESCE(@DOCUMENTO, bDocumento),
        nUpdatedBy = @USUARIO,
        tUpdatedAt = GETDATE()
    WHERE id = @ID
    SET @State = 1;
    SET @Message = 'Actualizacion Correcta'
    SET @CodeError = 0;
    END
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
