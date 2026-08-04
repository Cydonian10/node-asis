SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
    NOMBRE: [dbo].[usp_GetCursosSeccionPreUniversitaria]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Listar Cursos de Sección Pre Universitaria

    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetCursosSeccionPreUniversitaria]
    @TEMPORADA_ID INT
AS
BEGIN
    SELECT
        cursoId as cursoId,
        cCurso as curso,
        cAula as aula,
        cCentroDeEstudios as centroDeEstudios,
        cAreaAcademica as areaAcademica,
        cAreaCorricular as areaCorricular,
        idTemporada as temporadaId,
        idPeriodoLectivo as periodoLectivoId
    FROM Sync_CursoSeccionPreUniversitaria
    WHERE idTemporada = @TEMPORADA_ID
END
GO
