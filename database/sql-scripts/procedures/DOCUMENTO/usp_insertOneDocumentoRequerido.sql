CREATE OR ALTER PROCEDURE [MAO].[usp_InsertOneDocumentoRequerido]
    @NOMBRE VARCHAR(250),
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT,
    @Id INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY 
    IF EXISTS (SELECT 1
    FROM MAO.erp_t_documentoRequerido
    WHERE cNombre = @NOMBRE)
         BEGIN
         SET @Id = 0;
         SET @Message = ' ya existe un doumento con este nombre'
         SET @CodeError = -1;
         SET @State = -1;
    END

    INSERT INTO MAO.erp_t_documentoRequerido
        (cNombre, tCreated_at, cCreated_by, tUpdated_at, bEstado)
    VALUES ( @NOMBRE, GETDATE(), @USUARIO, GETDATE(), 1);

         SET @Id = SCOPE_IDENTITY();
         SET @Message = 'DOCUMENTO CREADO CORRECTAMENTE'
        SET @CodeError = 0;
        SET @State = 1;
     END TRY 
    BEGIN CATCH 
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1;
     END CATCH
END 
GO