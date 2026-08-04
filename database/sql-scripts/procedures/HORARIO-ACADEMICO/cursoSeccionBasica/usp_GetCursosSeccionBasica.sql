SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
    NOMBRE: [dbo].[usp_GetCursosSeccionBasica]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Listar Cursos de Sección

    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetCursosSeccionBasica]
    @PERIODO_LECTIVO_ID INT = NULL
AS
BEGIN
    SELECT
        cursoId as cursoId,
        cCurso as curso,
        nSeccionId as seccionId,
        cSeccion as seccion,
        cGrado as grado,
        cNivel as nivel,
        idPeriodoLectivo as periodoLectivo
    FROM Sync_CursoSeccionBasica
    WHERE idPeriodoLectivo = @PERIODO_LECTIVO_ID
END
GO
