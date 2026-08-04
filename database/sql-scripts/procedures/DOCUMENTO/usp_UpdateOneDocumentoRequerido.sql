CREATE OR ALTER PROCEDURE [MAO].[.usp_UpdateOneDocumentoRequerido]
    @NOMBRE VARCHAR(250),
    @USUARIO INT,
    @ID INT,
    @State INT OUTPUT ,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY 
    IF NOT EXISTS(SELECT 1
    FROM MAO.erp_t_documentoRequerido
    WHERE id = @ID)
    BEGIN 
        SET @State = -1;
        SET @Message = 'documento no encontrado';
        SET @CodeError = -1;
        RETURN;
    END

    IF EXISTS(SELECT 1
    FROM MAO.erp_t_documentoRequerido
    WHERE cNombre = @NOMBRE AND id <> @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'Ya existe un documento con ese nombre'
        SET @CodeError = -1;
        RETURN;
    END 
    UPDATE
    MAO.erp_t_documentoRequerido
    SET cNombre = @NOMBRE,
    cUpdated_by = @USUARIO,
    tUpdated_at = GETDATE()
    WHERE
    id = @ID

    SET @State = 1;
    SET @Message = 'El documento se actualizo correctamente';
    SET @CodeError = 0;

    END TRY
    BEGIN CATCH 
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END 
GO