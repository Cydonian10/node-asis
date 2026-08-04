SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteMarcacion]
-- Fecha:  18-09-2025
-- Descripcion: Procedimiento para eliminar un registro de marcacion
-- Parámetros: 'ID' 'USUARIO'
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_DeleteMarcacion]
    @ID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR (250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM Marcacion
    WHERE id = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'marcacion no encontrada'
        SET @CodeError = -1;
        RETURN;
    END 
    IF EXISTS(SELECT 1
    FROM AsistenciaRegular
    WHERE marcacionId_fk = @ID )
    BEGIN
        SET @State = -1;
        SET @Message = 'La marcacion se esta registrando en Asistencia Regular'
        SET @CodeError = -1;
        RETURN;
    END 
    IF EXISTS(SELECT 1
    FROM AsistenciaExtendida
    WHERE marcacionId_fk = @ID )
    BEGIN
        SET @State = -1;
        SET @Message = 'La marcacion se esta registrando en Asistencia Extendida'
        SET @CodeError = -1;
        RETURN;
    END

    UPDATE Marcacion
        SET nUpdatedBy = @USUARIO,
            tUpdateAt = GETDATE(),
            bEliminado = 1
        WHERE id = @ID
        SET @State = 0;
        SET @Message = 'Marcacion eliminado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
