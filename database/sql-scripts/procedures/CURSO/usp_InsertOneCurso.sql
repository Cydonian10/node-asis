CREATE OR ALTER PROCEDURE [MAO].[usp_InsertOneCurso]
    @NOMBRE VARCHAR(250),
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
    IF EXISTS (SELECT 1
    FROM MAO.erp_t_Curso
    WHERE cNombre = @NOMBRE)
        BEGIN
        SET @Id = 0;
        SET @Message = 'Ya existe un curso con ese nombre';
        SET @CodeError = -1;
        SET @State = -1;
        RETURN;
    END

    INSERT INTO MAO.erp_t_Curso
        (cNombre, tCreated_at, cCreated_by, tUpdated_at, bEstado)
    VALUES( @NOMBRE, GETDATE(), @USUARIO, GETDATE(), 1);
    
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'CURSO CREADO EXITOSAMENTE'
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