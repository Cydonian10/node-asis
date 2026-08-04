IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_UpdateRol'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_UpdateRol]
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateRol]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar un rol

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_UpdateRol]
    @ROL_ID INT,
    @TITULO VARCHAR(100),
    @DESCRIPCION VARCHAR(MAX),
    @SUPERVISION BIT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT

    BEGIN TRY  
        IF NOT EXISTS ( SELECT 1 FROM Rol WHERE id = @ROL_ID AND bEliminado = 0 )
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro no existe o ya ha sido eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        SET @TITULO = LTRIM(RTRIM(@TITULO));

        IF @TITULO = ''
        BEGIN
            SET @State = -1;
            SET @Message = 'El título no puede estar vacío.';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS ( SELECT 1 FROM Rol WHERE cTitulo COLLATE Latin1_General_CI_AS = @TITULO COLLATE Latin1_General_CI_AS AND (@ROL_ID IS NULL OR id <> @ROL_ID) and bEliminado = 0)
        BEGIN
            SET @State = 1;
            SET @Message = 'El titulo de Rol ya existe. No se puede duplicar.';
            SET @CodeError = 0;
            RETURN;
        END

        UPDATE Rol SET
            cTitulo = COALESCE(@TITULO, cTitulo),
            cDescripcion = COALESCE(@DESCRIPCION, cDescripcion),
            bSupervision = COALESCE(@SUPERVISION , bSupervision)
        WHERE id = @ROL_ID

        SET @AffectedRows = @@ROWCOUNT;
            
        IF (@AffectedRows > 0)
         BEGIN
            SET @State = 0;
            SET @Message = 'Rol actualizada correctamente.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO
