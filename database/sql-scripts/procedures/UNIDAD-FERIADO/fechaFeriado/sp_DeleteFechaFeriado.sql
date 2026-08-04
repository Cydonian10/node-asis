--==============================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteFechaFeriado]
-- Fecha:  06-10-2025
-- Descripcion: Procedimiento para eliminar un registro de Fecha feriado
--==============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_DeleteFechaFeriado]
    @ID INT,
    @USUARIO INT,
    @Message VARCHAR (250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM FechaFeriado
    WHERE id = @ID AND bEliminado = 0 )
    BEGIN
        SET @State = -1;
        SET @Message = 'id no valido'
        RETURN;
    END
   UPDATE FechaFeriado
   SET bEliminado = 1 
   WHERE id = @ID
   
   IF EXISTS (SELECT 1 
   FROM UnidadFeriado 
   WHERE fechaFeriadoId_pk = @ID)
   BEGIN
      DELETE uf
      FROM UnidadFeriado AS uf
      INNER JOIN FechaFeriado AS ff ON uf.fechaFeriadoId_pk = ff.id
      
    END

    SET @State = 1;
    SET @Message = 'Fecha ferido eliminado correctamente'
    SET @CodeError = 0;

    END TRY 
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO   
