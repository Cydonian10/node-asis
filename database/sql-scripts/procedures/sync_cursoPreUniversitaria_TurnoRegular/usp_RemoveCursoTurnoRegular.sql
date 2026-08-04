/*======================================================================================================
NOMBRE: [dbo].[usp_RemoveCursoTurnoRegular]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite eliminar un curso en el turno regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_RemoveCursoTurnoRegular]
  @CURSO_ID INT,
  @USUARIO INT,
  @State INT OUTPUT,
  @Message VARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE CursoSeccionPreUniversitaria_TurnoRegular
  SET bEliminado = 1,
      nUpdatedBy = @USUARIO,
      tUpdatedAt = GETDATE()
  WHERE id = @CURSO_ID
  ;

  SET @State = 1;
  SET @Message = 'Curso eliminado correctamente';
  SET @CodeError = 0;
END

