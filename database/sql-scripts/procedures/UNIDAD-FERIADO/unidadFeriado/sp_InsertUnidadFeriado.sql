--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[dbo].[dbo].[sp_InsertUnidadFeriado]
-- Fecha:  01-10-2025
-- Descripcion: Procedimiento para registrar los id de unidad y ferido
-- Parámetros: 'UNIDAD', 'FERIADO'
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_InsertUnidadFeriado]
    @UNIDAD INT,
    @FERIADO INT,
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
    FROM Unidad
    WHERE id = @UNIDAD) 
    BEGIN 
        SET @State =-1;
        SET @Message = 'la unidad no esa valida'
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM FechaFeriado 
    WHERE id = @FERIADO)
    BEGIN
        SET @Message = 'la fecha feriado no es valida'
        RETURN;
    END
    INSERT INTO UnidadFeriado (unidadId_pk, fechaFeriadoId_pk,nCreatedBy, tCreatedAt)
    VALUES (@UNIDAD, @FERIADO, @USUARIO, GETDATE())
        SET @Message = ' unidad feriado creado correctamente'
        SET @State = 1
        SET @CodeError= 0
    END TRY
    BEGIN CATCH 
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = 0
    END CATCH
END
GO 

SELECT * FROM UnidadFeriado
