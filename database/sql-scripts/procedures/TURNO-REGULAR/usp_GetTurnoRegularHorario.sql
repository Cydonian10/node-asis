--===================================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetTurnoRegularHorario]
-- Fecha:  01-10-2025
-- Descripcion: Procedimiento para mostrar los resgistros de Turno Regular a parti del id de Horario
-- Parámetros: 'IDHORARIO'
-- IDHORARIO: ID de un horario 
--===================================================================================================
CREATE OR ALTER PROCEDURE [dbo].[usp_GetTurnoRegularHorario]
    @HORARIOID INT,
    @FECHA_INICIO DATE = NULL,
    @FECHA_FIN DATE = NULL,
    @Message VARCHAR (250) OUTPUT

AS
BEGIN
    SET NOCOUNT ON ;

    IF NOT EXISTS (SELECT 1
    FROM HorarioDias
    WHERE horarioId_fk = @HORARIOID)
    BEGIN
        SET @Message = 'No hay turnos configurados para este horario'
        RETURN;
    END
    SELECT t.id AS id,
        hd.id as horarioDiaId,
        t.orden as orden,
        --h.id AS id_horario, hd.id AS Id_HD,
        h.cTitulo AS horario,
        d.cTitulo AS dia,
        CAST(t.horaInicio AS VARCHAR(5)) AS horaInicio,
        h.horaDia as totalHoras,
        tipo = CASE 
 WHEN  bTipo = 1  THEN 'Salida'
 WHEN bTipo = 0  THEN 'Entrada'
 END,
        turno = CASE 
    WHEN (t.orden + 1)/ 2 = FLOOR((t.orden +1) / 2)
    THEN 'Turno' + CONVERT(varchar,(t.orden + 1) / 2)
 END,
        libre = CASE 
    WHEN hd.bLibre = 1 THEN 'Si'
    WHEN hd.bLibre = 0 THEN 'No'
 END,
        CAST(v.tFechaInicio AS VARCHAR(12)) AS fechaInicio,
        CAST(v.tFechaFin AS VARCHAR(12))AS fechaFin
    FROM TurnoRegular AS t
        INNER JOIN HorarioDias AS hd ON t.horarioDiasId_fk = hd.id
        INNER JOIN Horario AS h ON hd.horarioId_fk = h.id
        INNER JOIN Dia As d ON hd.diaId_fk = d.id
        LEFT JOIN Vigencia v ON hd.id = v.horarioDiasId_fk
    WHERE h.id = @HORARIOID AND t.bEliminado = 0 AND hd.bLibre = 0 AND v.bActivo = 1
    AND (@FECHA_INICIO IS NULL OR v.tFechaInicio = @FECHA_INICIO) AND (@FECHA_FIN IS NULL OR v.tFechaFin = @FECHA_FIN)
    GROUP BY h.id, hd.id, t.id, t.orden, h.cTitulo, d.cTitulo, h.horaDia, t.horaInicio, t.bTipo, bLibre ,d.orden,v.tFechaInicio, v.tFechaFin
    
--  ORDER BY d.orden

END
GO
