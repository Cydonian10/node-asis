IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_InsertRol'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_InsertRol]
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertRol]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear rol que se va supervisaar en el sistema

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
 CREATE OR ALTER PROCEDURE [dbo].[usp_InsertRol]
    @UNIDAD_ID INT,
    @TITULO VARCHAR(100),
    @DESCRIPCION VARCHAR(MAX),
    @SUPERVISION BIT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @TITULO = LTRIM(RTRIM(@TITULO));
        SET @DESCRIPCION = LTRIM(RTRIM(@DESCRIPCION));

        IF @TITULO = '' and @DESCRIPCION = ''
        BEGIN
            SET @State = -1;
            SET @Message = 'El título y descripción no puede estar vacío.';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS ( SELECT 1 FROM Unidad WHERE id = @UNIDAD_ID AND bEliminado = 0 )
        BEGIN
            SET @State = -1;
            SET @Message = 'Unidad no existe o ya ha sido eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS ( SELECT 1 FROM Rol WHERE cTitulo COLLATE Latin1_General_CI_AS = @TITULO COLLATE Latin1_General_CI_AS AND (@Id IS NULL OR Id <> @Id) AND unidadId_fk = @UNIDAD_ID and bEliminado = 0)
        BEGIN
            SET @Id = SCOPE_IDENTITY();
            SET @State = -1;
            SET @Message = 'El nombre ya existe. No se puede duplicar.';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO API_SCAP_DB.dbo.Rol
            ( unidadId_fk, cTitulo, cDescripcion, bSupervision, bEliminado, nCreatedBy, tCreatedAt )
        VALUES
            ( @UNIDAD_ID, @TITULO, @DESCRIPCION, @SUPERVISION, 0, @USER, getdate());

            SET @Id = SCOPE_IDENTITY();
            SET @State = 1;
            SET @Message = 'Rol registrado correctamente.';
            SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @Id = 0;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
