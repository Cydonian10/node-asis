--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetTurnoExtendidoHorario]
-- Fecha:  01-10-2025
-- Descripcion: Procedimiento para mostrar los resgistros de Turno Extendido por Horario
-- Parámetros: 'IDHORARIO'
-- IDHORARIO: ID de un horario 
--=======================================================================================
CREATE OR ALTER  PROCEDURE [dbo].[usp_GetTurnoExtendidoHorario]
    @IDHORARIO INT,
    @FECHA_INICIO DATE= NULL,
    @FECHA_FIN DATE = NULL,
    @Message VARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        te.id as id,
        h.id as horarioId,
        hd.id as horarioDiasId,
        h.cTitulo as horario,
        d.cTitulo as dia,
        CAST(te.horaInicio AS VARCHAR(5)) AS horaInicio,
        CAST(te.horaFin AS VARCHAR(5)) AS horaFin,
        hd.bLibre as diaLibre,
        CASE 
            WHEN cd.diasId_pk = dc.id  THEN dc.cTitulo
            ELSE 'sin dia'
        END as diaFin,
        cd.diasId_pk as diaFinId,
         CAST(v.tFechaInicio AS VARCHAR(12)) AS fechaInicio,
        CAST(v.tFechaFin AS VARCHAR(12))AS fechaFin
    FROM Horario h
        INNER JOIN HorarioDias hd on hd.horarioId_fk = h.id
        INNER JOIN Dia d on d.id = hd.diaId_fk
        LEFT JOIN TurnoExtendido te on te.horarioDiasId_fk = hd.id
        LEFT JOIN ConectadoDias AS cd ON cd.turnoExtendidoId_pk = te.id
        LEFT JOIN Dia AS dc ON cd.diasId_pk = dc.id
        LEFT JOIN Vigencia v ON hd.id = v.horarioDiasId_fk
    WHERE h.id = @IDHORARIO AND
    h.bEliminado = 0 AND
        hd.bEliminado = 0 AND
        d.bEliminado = 0 AND
        te.bEliminado = 0 AND
        v.bActivo = 1
    AND (@FECHA_INICIO IS NULL OR v.tFechaInicio = @FECHA_INICIO) AND (@FECHA_FIN IS NULL OR v.tFechaFin = @FECHA_FIN)
    

END

GO
