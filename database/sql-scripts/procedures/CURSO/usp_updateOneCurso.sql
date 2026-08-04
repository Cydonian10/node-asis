CREATE or ALTER PROCEDURE [MAO].[usp_UpdateOneCurso]
    @ID INT,
    @USUARIO INT,
    @NOMBRE VARCHAR(250),
    @Message VARCHAR(250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT 
AS
BEGIN
    SET NOCOUNT,XACT_ABORT ON;

    BEGIN TRY 
    IF NOT EXISTS(SELECT 1
    FROM MAO.erp_t_Curso
    WHERE id = @ID)BEGIN
        SET @State = -1;
        SET @Message = 'curso no encontrado'
        SET @CodeError = -1;
        RETURN;
    END

    IF EXISTS (
        SELECT 1
    FROM MAO.erp_t_Curso
    WHERE cNombre = @NOMBRE AND id <> @ID)
    BEGIN 
        SET @State = -1;
        SET @Message = 'Ya existe un curso con ese nombre';
        SET @CodeError = -1;
        RETURN;
    END 
    UPDATE
    MAO.erp_t_Curso
    SET cNombre = @NOMBRE,
    cUpdated_by = @USUARIO,
    tUpdated_at = GETDATE()
    WHERE
    id = @ID

    SET @State = 1;
    SET @Message = 'Actualizado corretamente';
    SET @CodeError = 0;

    END TRY
    BEGIN CATCH 
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO 