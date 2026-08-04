SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_UpdateMarcacion]
-- Fecha:  18-09-2025
-- Descripcion: Procedimiento para crear un registro de marcacion
-- Parámetros: 'ID', 'USUARIO','PUNCHSTATE', 'PUNCHSTIME'
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_UpdateMarcacion]
    @ID INT,
    @USUARIO INT,
    @PUNCHSTATE VARCHAR(5),
    @PUNCHTIME DATETIME,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
 XACT_ABORT ON;
    BEGIN TRY 
     IF NOT EXISTS (SELECT 1
     FROM Marcacion
     WHERE id = @ID AND bEliminado = 0)
     BEGIN
        SET @State = -1;
        SET @Message = 'Marcación no encontrada'
        SET @CodeError = -1;
        RETURN;
     END
    UPDATE Marcacion
    SET punch_time = COALESCE (@PUNCHTIME, punch_time),
        punch_state = COALESCE (@PUNCHSTATE, punch_state),
        nCreatedBy = @USUARIO,
        tCreatedAt = GETDATE()
    WHERE Id = @ID
        SET @State = 1;
        SET @Message = 'Actualización correcta'
        SET @CodeError= 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
