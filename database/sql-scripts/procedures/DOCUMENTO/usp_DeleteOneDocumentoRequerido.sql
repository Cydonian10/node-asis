CREATE OR ALTER PROCEDURE [MAO].[usp_DeleteOneDocumentoRequerido]
    @ID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT

AS 
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
--SELECT * FROM MAO.erp_d_documentoRequeridoAdmision
    BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM MAO.erp_t_documentoRequerido
    WHERE id = @ID )
    BEGIN
        SET @State = -1;
        SET @Message = 'Documento requerido no encontrado'; 
        SET @CodeError = 1;
        RETURN;
    END
    IF EXISTS(SELECT 1
    FROM MAO.erp_d_documentoRequeridoAdmision
    WHERE id_documento = @ID)
    BEGIN 
        SET @State = -1;
        SET @Message = 'Documento en uso';
        SET @CodeError = 1;
        RETURN;
    END

    UPDATE
        MAO.erp_t_documentoRequerido
    SET bEstado = 0,
        cUpdated_by = @USUARIO,
        tUpdated_at = GETDATE()
    WHERE id = @ID

    SET @State = 0;
    SET @Message = 'Documento eliminado Correctamente';
    SET @CodeError = 0;
    END TRY
    BEGIN CATCH 
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
