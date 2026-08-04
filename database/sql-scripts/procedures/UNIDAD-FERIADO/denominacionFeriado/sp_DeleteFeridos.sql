--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteFeriado]
-- Fecha:  06-09-2025
-- Descripcion: Procedimiento para eliminar de forma logica los datos de denominacion de feriado 
-- Parámetros:
-- ID: El ID de un registro de la tabla DenominacionFeriado (int)
-- USUARIO: Id del usuario que realiza la elimincion (int)
--=========================================================================================
CREATE OR ALTER PROCEDURE[dbo].[sp_DeleteFeriados]
    @ID INT,
    @USUARIO INT,
    @Message VARCHAR(250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY 
    IF NOT EXISTS ( SELECT 1
    FROM DenominacionFeriado 
    WHERE id = @ID AND bEliminado = 0)
    BEGIN 
        SET @State = -1;
        SET @Message = 'El feriado no es valido o fue eliminado'
        RETURN;
    END
    
    IF EXISTS (SELECT 1
    FROM FechaFeriado
    WHERE denominacionFeriadoId_fk = @ID AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'El feriado esta en uso'
        RETURN;
    END

    UPDATE DenominacionFeriado 
        SET bEliminado = 1,
            nUpdatedBy = @USUARIO,
            tUpdatedAt = GETDATE()
        WHERE id = @ID
        SET @State = 1
        SET @Message = 'Eliminado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
