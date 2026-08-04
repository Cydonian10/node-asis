--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertMotivo]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para crear un nuevo registro de Motivo
-- Parámetros: 'NOMBRE', 'DETALLE', 'USUARIO'
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_InsertMotivo]
    @NOMBRE VARCHAR (250),
    @DETALLE VARCHAR(250),
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR (250) OUTPUT,
    @CodeError INT OUTPUT,
    @Id INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY 
    IF EXISTS (SELECT 1
    FROM Motivo
    WHERE nombre = @NOMBRE )
    BEGIN
        SET @ID = 0;
        SET @Message ='ya existe un motivo con ese titulo'
        RETURN;
    END  
    IF NULLIF(LTRIM(@NOMBRE) , '') IS NULL
    BEGIN 
        SET @Message = 'no se permite espacios en blanco'
        RETURN;
    END
    IF NOT @NOMBRE LIKE '%[a-zA-Z]%'
    BEGIN
        SET @Message = 'no se permite ingresar números en el nombre'
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM Motivo 
    WHERE detalle = @DETALLE)
    BEGIN
        SET @ID = 0;
        SET @Message = 'ya existe un motivo con ese detalle'
        RETURN;
    END
    IF NULLIF(LTRIM(@DETALLE), '') IS NULL
    BEGIN 
        SET @Message = 'No se permite espacios en blanco'
        RETURN;
    END
    INSERT INTO Motivo
    (nombre, detalle, nCreatedBy, tCreatedAt)
    VALUES 
    (@NOMBRE, @DETALLE, @USUARIO, GETDATE());
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Motivo creado correctamente'
        SET @CodeError = 0;
        SET @State = -1;
    END TRY 
    BEGIN CATCH
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO