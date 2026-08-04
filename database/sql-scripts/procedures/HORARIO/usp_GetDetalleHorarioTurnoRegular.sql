/*======================================================================================================
NOMBRE: [dbo].[usp_GetDetalleHorarioTurnoRegular]
FECHA: 01-10-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Detalle de horario de turno regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetDetalleHorarioTurnoRegular]
    @HORARIO_ID INT = NULL
AS
BEGIN
    ;WITH
        Entradas
        AS
        (
            SELECT
                tr.id turnoEntradaId,
                h.id AS horarioId,
                h.cTitulo AS horario,
                d.cTitulo AS dia,
                tr.horaInicio AS horaEntrada,
                ROW_NUMBER() OVER (PARTITION BY h.id, d.id ORDER BY tr.orden) AS rn,
                hd.bLibre,
                csbtr.id as cursoPreUniversitarioTurnoRegularId, -- representa el id CursoTurnoRegular
                csps.cursoPreUniversitario as curso,
                csps.centroEstudios as centroEstudios
            FROM Horario h
                INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
                INNER JOIN Dia d ON d.id = hd.diaId_fk
                LEFT JOIN TurnoRegular tr
                ON tr.horarioDiasId_fk = hd.id
                    AND tr.bEliminado = 0
                    AND tr.bTipo = 0
                left JOIN CursoSeccionPreUniversitaria_TurnoRegular csbtr
                ON csbtr.turnoRegularEntradaId = tr.id
                    AND csbtr.bEliminado = 0
                left JOIN Sync_CursoSeccionPreUniversitaria csps
                ON csps.id = csbtr.syncCursoSeccionPreUniversitariaId
            WHERE h.bEliminado = 0
                AND hd.bEliminado = 0
                AND d.bEliminado = 0
                AND h.id = @HORARIO_ID
        ),
        Salidas
        AS
        (
            SELECT
                tr.id turnoSalidaId,
                h.id AS horarioId,
                d.cTitulo AS dia,
                tr.horaInicio AS horaSalida,
                ROW_NUMBER() OVER (PARTITION BY h.id, d.id ORDER BY tr.orden) AS rn
            FROM Horario h
                INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
                INNER JOIN Dia d ON d.id = hd.diaId_fk
                LEFT JOIN TurnoRegular tr
                ON tr.horarioDiasId_fk = hd.id
                    AND tr.bEliminado = 0
                    AND tr.bTipo = 1
            WHERE h.bEliminado = 0
                AND hd.bEliminado = 0
                AND d.bEliminado = 0
                AND h.id = @HORARIO_ID
        )
    SELECT
        e.horarioId,
        e.horario,
        e.dia,
        e.turnoEntradaId,
        e.horaEntrada,
        s.turnoSalidaId,
        s.horaSalida,
        e.cursoPreUniversitarioTurnoRegularId,
        e.curso,
        e.centroEstudios,
        CASE WHEN e.bLibre = 1 THEN 'SI' ELSE 'NO' END AS diaLibre
    FROM Entradas e
        LEFT JOIN Salidas s
        ON e.horarioId = s.horarioId
            AND e.dia = s.dia
            AND e.rn = s.rn
END
GO


