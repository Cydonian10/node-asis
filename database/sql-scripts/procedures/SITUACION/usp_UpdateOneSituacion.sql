IF EXISTS (
  SELECT * 
   FROM INFORMATION_SCHEMA.ROUTINES
  WHERE SPECIFIC_SCHEMA = N'dbo'
   AND SPECIFIC_NAME = N'usp_UpdateOneSituacion'
   AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE [dbo].[usp_UpdateOneSituacion]
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertOneSituacion]
FECHA: 31-07-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crea una situacion

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_UpdateOneSituacion]
  @Id INT,
  @Nombre VARCHAR(50) = NULL,
  @ORDEN INT = NULL,
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

    -- Validación: el nombre no debe existir en otro registro
    IF EXISTS (
      SELECT 1
      FROM Situacion
      WHERE cNombre COLLATE Latin1_General_CI_AI = @Nombre COLLATE Latin1_General_CI_AI
        AND Id <> @Id
    )
    BEGIN
      SET @State = -1;
      SET @Message = 'Ya existe otra situación con ese nombre';
      SET @CodeError = -1;
      RETURN;
    END

    IF EXISTS (
      SELECT 1
      FROM Situacion
      WHERE nOrden = @ORDEN
        AND Id <> @Id
    )
    BEGIN
      SET @State = -1;
      SET @Message = 'Ya existe otra situación con ese orden';
      SET @CodeError = -1;
      RETURN;
    END

    UPDATE Situacion
    SET 
        cNombre = ISNULL(@Nombre, cNombre),
        nOrden = ISNULL(@ORDEN, nOrden),
        nUpdatedBy = @User,
        tUpdatedAt = GETDATE()
    WHERE Id = @Id;

    IF @@ROWCOUNT = 0
    BEGIN
      SET @State = -1;
      SET @Message = 'No se encontró la situación';
      SET @CodeError = -1;
      RETURN;
    END

    SET @State = 1;
    SET @Message = 'Situación actualizada correctamente';
    SET @CodeError = 0;
  END TRY
  BEGIN CATCH
    SET @State = 1;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
  END CATCH
END
GO