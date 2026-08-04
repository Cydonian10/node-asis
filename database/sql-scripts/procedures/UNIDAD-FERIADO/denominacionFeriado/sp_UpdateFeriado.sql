--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_UpdateFeriado]
-- Fecha:  27-09-2025
-- Descripcion: Procedimiento para actualizar datos de una denominacion de feriado 
-- Parámetros:
-- 'ID : el ID de un registro de la tabla DenominacionFeriado'
-- 'CODIGO: Es el codigo que se le asigna al registro puede ser alfanumerico
-- 'DENOMINACION: Es el nombre que se le asigna al feriado'
-- 'DESCRIPCION: Es la descripcion que se le asigna al feriado este campo no es obligatorio'
--=========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_UpdateFeriado]
    @ID INT,
    @USUARIO INT,
    @CODIGO CHAR(10) = NULL,
    @DENOMINACION VARCHAR(250) = NULL,
    @DESCRIPCION VARCHAR(250) = NULL,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT 
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
IF EXISTS (SELECT 1
        FROM DenominacionFeriado
        WHERE cDenominacion = @DENOMINACION AND bEliminado = 0)
            BEGIN 
                SET @State =-1;
                SET @Message = 'Ya existe un registro con esta denominacion'
                RETURN;
            END
        
        IF EXISTS (SELECT 1
        FROM DenominacionFeriado
        WHERE codigo = @CODIGO AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'el codigo ya fue registrado'
            RETURN;
        END
        UPDATE DenominacionFeriado
            SET codigo = COALESCE(@CODIGO, codigo),
                cDenominacion = COALESCE(@DENOMINACION, cDenominacion),
                cDescripcion =  COALESCE (@DESCRIPCION, cDescripcion),
                nUpdatedBy= @USUARIO,
                tUpdatedAt = GETDATE()
            WHERE 
                id = @ID
                SET @State = 1;
                SET @Message = 'Actualizacion correcta'
                SET @CodeError = 0;
        END TRY
        BEGIN CATCH
            SET @State = -1;
            SET @Message = ERROR_MESSAGE();
            SET @CodeError = ERROR_NUMBER();
        END CATCH
END
GO

