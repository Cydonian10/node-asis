/*======================================================================================================
NOMBRE: [dbo].[usp_GetOneCursoTurnoRegular]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite agregar un nuevo curso en el turno regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetOneCursoTurnoRegular]
  @CURSO_TURNOREGULAR_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    csptr.id, -- id CursoTurnoRegular
    cpu.cursoPreUniversitario,
    cpu.centroEstudios
  FROM
    CursoSeccionPreUniversitaria_TurnoRegular as csptr
    INNER JOIN
    Sync_CursoSeccionPreUniversitaria cpu
    ON cpu.id = csptr.syncCursoSeccionPreUniversitariaId
  WHERE 
    csptr.id = @CURSO_TURNOREGULAR_ID
    AND bEliminado = 0;
END
GO



