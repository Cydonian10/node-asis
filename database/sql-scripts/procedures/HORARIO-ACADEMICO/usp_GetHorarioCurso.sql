--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetHorarioCurso]
-- Fecha:  24-10-2025
-- Descripcion: Procedimiento para mostrar Todos los cursos de un Horario Academico
-- Parámetros: 'HORARIOID
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorarioCurso]
    @HORARIOID INT

AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.id AS Id_turno,
        h.cTitulo AS Horario,
        d.cTitulo AS Dia,
        t.horaInicio AS Hora,
        Tipo = CASE 
        WHEN t.bTipo = 1 THEN 'Salida'
        WHEN t.bTipo = 0 THEN 'Entrada'
    END,
        Turno = CASE 
        WHEN (t.orden + 1) / 2 = FLOOR((t.orden + 1) / 2)
        THEN 'Turno' + CONVERT(varchar, (t.orden + 1) / 2)
    END,
        cp.cCurso,
        cp.cAula
    FROM TurnoRegular AS t
        INNER JOIN HorarioDias AS hd
        ON t.horarioDiasId_fk = hd.id
        INNER JOIN Horario AS h
        ON hd.horarioId_fk = h.id
        INNER JOIN Dia AS d
        ON hd.diaId_fk = d.id
        INNER JOIN CursoSeccionPreUniversitaria_TurnoRegular AS ct
        ON (ct.turnoRegularEntradaId = t.id OR ct.turnoRegularSalidaId = t.id )
        INNER JOIN Sync_CursoSeccionPreUniversitaria AS cp
        ON ct.syncCursoSeccionPreUniversitariaId = cp.cursoId
    WHERE h.id = @HORARIOID
        AND t.bEliminado = 0
    ORDER BY d.orden ASC

END 
GO