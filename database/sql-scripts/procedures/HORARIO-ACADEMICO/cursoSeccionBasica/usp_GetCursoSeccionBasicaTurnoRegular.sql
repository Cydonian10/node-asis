SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
    NOMBRE: [dbo].[usp_GetCursoSeccionBasicaTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Obtener registros de la tabla CursoSeccionBasica_TurnoRegular que pertencen a un turno regular específico
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetCursoSeccionBasicaTurnoRegular]
    @TURNO_REGULAR_ENTRADA_ID INT,
    @TURNO_REGULAR_SALIDA_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        csbtr.id,
        csb.cCursoEducacionBasica as curso,
        csb.cSeccion as seccion,
        trEntrada.horaInicio as horaInicio,
        trSalida.horaInicio as horaFin
    FROM CursoSeccionBasica_TurnoRegular csbtr
        INNER JOIN TurnoRegular trEntrada
            ON csbtr.turnoRegularEntradaId = trEntrada.id
        INNER JOIN TurnoRegular trSalida
            ON csbtr.turnoRegularSalidaId = trSalida.id
        INNER JOIN Sync_CursoSeccionBasica csb
            ON csbtr.syncCursoSeccionId = csb.cursoId
    WHERE csbtr.turnoRegularEntradaId = @TURNO_REGULAR_ENTRADA_ID
      AND csbtr.turnoRegularSalidaId = @TURNO_REGULAR_SALIDA_ID
      AND csbtr.bEliminado = 0
      AND trEntrada.bEliminado = 0
      AND trSalida.bEliminado = 0
END
GO

SELECT * FROM Sync_CursoSeccionBasica