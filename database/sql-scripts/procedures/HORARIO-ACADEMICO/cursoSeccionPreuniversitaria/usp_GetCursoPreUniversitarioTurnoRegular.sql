SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
    NOMBRE: [dbo].[usp_GetCursoPreUniversitarioTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Obtener registros de la tabla CursoSeccionPreUniversitaria_TurnoRegular que pertencen a un turno regular específico
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetCursoPreUniversitarioTurnoRegular]
    @TURNO_REGULAR_ENTRADA_ID INT,
    @TURNO_REGULAR_SALIDA_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        csptr.id,
        cspu.cCurso as curso,
        cspu.cAula as aula,
        trEntrada.horaInicio as horaInicio,
        trSalida.horaInicio as horaFin,
        cspu.cCentroDeEstudios as centroDeEstudios
    FROM CursoSeccionPreUniversitaria_TurnoRegular csptr
        INNER JOIN Sync_CursoSeccionPreUniversitaria cspu
            ON csptr.syncCursoSeccionPreUniversitariaId = cspu.cursoId
        INNER JOIN TurnoRegular trEntrada
            ON csptr.turnoRegularEntradaId = trEntrada.id
        INNER JOIN TurnoRegular trSalida
            ON csptr.turnoRegularSalidaId = trSalida.id
    WHERE csptr.turnoRegularEntradaId = @TURNO_REGULAR_ENTRADA_ID
      AND csptr.turnoRegularSalidaId = @TURNO_REGULAR_SALIDA_ID
      AND csptr.bEliminado = 0
      AND trEntrada.bEliminado = 0
      AND trSalida.bEliminado = 0
END
GO
