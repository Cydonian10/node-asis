IF EXISTS (
  SELECT * 
  FROM INFORMATION_SCHEMA.ROUTINES
  WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'usp_InsertOneSituacion'
    AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE [dbo].[usp_InsertOneSituacion]
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertOneSituacion]
FECHA: 31-07-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crea una situacion

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_InsertOneSituacion]
  @NOMBRE VARCHAR(50),
  @ORDEN INT,
  @User INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @Id INT OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    IF EXISTS (
      SELECT 1 
      FROM Situacion
      WHERE cNombre COLLATE Latin1_General_CI_AI = @Nombre COLLATE Latin1_General_CI_AI
    )
    BEGIN
      SET @Id = 0;
      SET @Message = 'Ya existe una situación con ese nombre';
      SET @CodeError = -1;
      set @State = -1;
      RETURN;
    END

    IF EXISTS (
      SELECT 1 
      FROM Situacion
      WHERE nOrden = @ORDEN
    )
    BEGIN
      SET @Id = 0;
      SET @Message = 'Ya existe una situación con ese orden';
      SET @CodeError = -1;
      set @State = -1;
      RETURN;
    END


    INSERT INTO Situacion (cNombre, nOrden, nCreatedBy, tCreatedAt)
    VALUES (@Nombre, @ORDEN ,@User, GETDATE());

    SET @Id = SCOPE_IDENTITY();
    SET @Message = 'Situación creada correctamente';
    SET @CodeError = 0;
    set @State = 1;
  END TRY
  BEGIN CATCH
    SET @Id = 0;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
    SET @State = -1;
  END CATCH
END
GO
