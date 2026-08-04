IF EXISTS (
  SELECT * 
   FROM INFORMATION_SCHEMA.ROUTINES
  WHERE SPECIFIC_SCHEMA = N'dbo'
   AND SPECIFIC_NAME = N'usp_DeleteOneSituacion'
   AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE [dbo].[usp_DeleteOneSituacion]
GO
CREATE PROCEDURE [dbo].[usp_DeleteOneSituacion]
  @Id INT,
  @User INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM Situacion WHERE Id = @Id)
    BEGIN
      SET @State = -1;
      SET @Message = 'Situación no encontrada';
      SET @CodeError = -1;
      RETURN;
    END

    -- Eliminar parcialmente
    update Situacion
      SET bEliminado = 1
    WHERE id = @Id

    SET @State = 0;
    SET @Message = 'Situación eliminada correctamente';
    SET @CodeError = 0;
  END TRY
  BEGIN CATCH
    SET @State = 1;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
  END CATCH
END
