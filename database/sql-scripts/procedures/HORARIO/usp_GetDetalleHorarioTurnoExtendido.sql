/*======================================================================================================
NOMBRE: [dbo].[usp_GetDetalleHorarioTurnoExtendido]
FECHA: 01-10-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Detalle de horario de turno extendido

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetDetalleHorarioTurnoExtendido]
    @HORARIO_ID INT = NULL
AS
BEGIN
    SELECT
        te.id as turnoExtendidoId,
        h.id horarioId,
        h.cTitulo as horario,
        d.cTitulo as dia,
        te.horaInicio as horaInicio,
        te.horaFin as horaFin,
        -- CASE 
        --     WHEN tr.bTipo = 1 THEN 'SALIDA'
        --     ELSE 'ENTRADA'
        -- END as tipoTurno,
        hd.bLibre as diaLibre
    FROM Horario h
        INNER JOIN HorarioDias hd on hd.horarioId_fk = h.id
        INNER JOIN Dia d on d.id = hd.diaId_fk
        LEFT JOIN TurnoExtendido te on te.horarioDiasId_fk = hd.id
    WHERE 
    h.bEliminado = 0 AND
        hd.bEliminado = 0 AND
        d.bEliminado = 0 AND
        te.bEliminado = 0 AND
        h.id = @HORARIO_ID
END
GO
