/*======================================================================================================
NOMBRE: [dbo].[usp_AddCursoBasicoTurnoRegular]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite agregar un nuevo curso en el turno regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_AddCursoBasicoTurnoRegular]
  @CURSO_ID INT,
  @TURNO_REGULAR_ENTRADA INT,
  @TURNO_REGULAR_SALIDA INT,
  @USUARIO INT,
  @State INT OUTPUT,
  @Message VARCHAR(250) OUTPUT,
  @Id INT OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO CursoSeccionBasica_TurnoRegular
    (syncCursoSeccionId, turnoRegularEntradaId, turnoRegularSalidaId, nCreatedBy)
  VALUES
    (@CURSO_ID, @TURNO_REGULAR_ENTRADA, @TURNO_REGULAR_SALIDA, @USUARIO);

  SET @State = 1;
  SET @Message = 'Curso agregado correctamente';
  SET @Id = SCOPE_IDENTITY();
  SET @CodeError = 0;
END
GO



