--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertFeriado]
-- Fecha:  27-09-2025
-- Descripcion: Procedimiento para crear una denominacion de feriado 
-- Parámetros:
-- 'CODIGO: Es el codigo que se le asigna al registro puede ser alfanumerico
-- 'DENOMINACION: Es el nombre que se le asigna al feriado'
-- 'DESCRIPCION: Es la descripcion que se le asigna al feriado este campo no es obligatorio'
--=========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_InsertFeriado]
    @CODIGO CHAR(10),
    @DENOMINACION VARCHAR(250),
    @DESCRIPCION VARCHAR(250),
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT,
    @Id INT OUTPUT
AS
BEGIN 
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
    IF EXISTS (SELECT 1
    FROM DenominacionFeriado
    WHERE cDenominacion = @DENOMINACION)
    BEGIN
        SET @State =-1;
        SET @Message ='Ya se registro un feriado con esta denominacion'
        RETURN;
    END
    IF NULLIF(LTRIM(RTRIM(@DENOMINACION)), '') IS NULL
        BEGIN 
            SET @Message = 'no se permite ingresar campos en blanco'
            RETURN;
        END
    INSERT INTO DenominacionFeriado (codigo, cDenominacion, cDescripcion, nCreatedBy, tCreatedAt)
    VALUES (@CODIGO, @DENOMINACION,@DESCRIPCION,@USUARIO, GETDATE());
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Feriado creado correctamente';
        SET @State = 1;
        SET @CodeError = 0
    END TRY
    BEGIN CATCH
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1
    END CATCH
END
GO