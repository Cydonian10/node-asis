CREATE OR ALTER PROCEDURE [MAO].[usp.DeleteOneCurso]
@ID INT,
@USUARIO INT,
@State INT OUTPUT,
@Message VARCHAR(250) OUTPUT,
@CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM erp_t_Curso
    WHERE id = @ID)
    BEGIN 
        SET @State = -1;
        SET @Message = 'Curso no encontrado'
        SET @CodeError = -1;
        RETURN; 
    END 

    UPDATE 
        MAO.erp_t_Curso
    SET bEstado = 0,
        cUpdated_by = @USUARIO,
        tUpdated_at = GETDATE()
    WHERE id = @ID

    SET @State = 0;
    SET @Message = 'curso eliminado correctamente';
    SET @CodeError = 0;
    END TRY
    BEGIN CATCH 
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH 
END
GO