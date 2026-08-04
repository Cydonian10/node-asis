/*======================================================================================================
NOMBRE: [dbo].[usp_GetDetalleHorarioGeneral]
FECHA: 17-09-2025
AUTOR: Admer Vasquez Uscuvilca
OBJETIVO: Lista los turnos de horario ya sea turno extendido o regular

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetDetalleHorarioGeneral]
  @HORARIO_ID INT,
  @ROL_USUARIO_ID INT,
  @FECHA_INICIO DATE,
  @FECHA_FIN DATE

AS
BEGIN
  SET NOCOUNT ON;

  WITH
    TurnosNumerados
    AS
    (
      SELECT
        h.id AS horarioId,
        h.cTitulo AS horario,
        d.cTitulo AS dia,
        d.id AS diaId,
        hd.bLibre,
        tr.id AS turnoRegularId,
        tr.horaInicio AS horaTurnoRegular,
        te.id AS turnoExtendidoId,
        te.horaInicio AS horaTurnoExtendido,
        te.horaFin AS horaFinTurnoExtendido,
        -- CASE 
        --   WHEN p.id is not null OR p2.id is not null THEN 1
        --   ELSE 0
        -- END AS permiso,
        -- CASE 
        --   WHEN j.id is not null OR j2.id is not null THEN 1
        --   ELSE 0
        -- END AS justificacion,
        -- Identificar tipo de turno
        CASE 
      WHEN te.id IS NOT NULL THEN 'Extendido'
      WHEN tr.id IS NOT NULL THEN 'Regular'
      ELSE NULL
    END AS tipoTurno,
        -- Numerar los turnos regulares por día
        ROW_NUMBER() OVER (PARTITION BY hd.id ORDER BY COALESCE(tr.horaInicio, te.horaInicio)) AS numeroTurno,
        cd.diasId_pk AS conectadoDiaId,
        v.tFechaInicio AS vigenciaInicio,
        v.tFechaFin AS vigenciaFin
      FROM Horario h
        INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
        INNER JOIN Dia d ON d.id = hd.diaId_fk
        LEFT JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id and tr.bEliminado = 0

        LEFT JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id and te.bEliminado = 0

        LEFT JOIN ConectadoDias cd on cd.turnoExtendidoId_pk = te.id
        LEFT JOIN Vigencia v on v.horarioDiasId_fk = hd.id and v.bActivo = 1
      WHERE h.id = @HORARIO_ID 
        AND v.tFechaInicio >= @FECHA_INICIO
        AND v.tFechaFin <= @FECHA_FIN
    ),
    TurnosEmparejados
    AS
    (
      SELECT
        t1.horarioId,
        t1.horario,
        t1.dia,
        t1.diaId,
        t1.bLibre,
        -- Turno de entrada
        COALESCE(t1.turnoRegularId, t1.turnoExtendidoId) AS turnoEntradaId,
        COALESCE(t1.horaTurnoRegular, t1.horaTurnoExtendido) AS horaEntrada,
        -- Turno de salida
        COALESCE(t2.turnoRegularId, t1.turnoExtendidoId) AS turnoSalidaId,
        COALESCE(t2.horaTurnoRegular, t1.horaFinTurnoExtendido) AS horaSalida,
        -- Tipo de turno
        t1.tipoTurno,
        t1.conectadoDiaId,
        t1.vigenciaInicio,
        t1.vigenciaFin
        
      -- t1.permiso,
      -- t1.justificacion
      FROM TurnosNumerados t1
        LEFT JOIN TurnosNumerados t2
        ON t1.diaId = t2.diaId
          AND t1.numeroTurno % 2 = 1 -- Solo turnos impares (entrada)
          AND t2.numeroTurno = t1.numeroTurno + 1
      -- El siguiente turno (salida)
      WHERE t1.numeroTurno % 2 = 1 OR t1.turnoExtendidoId IS NOT NULL
    )
  SELECT
    horarioId,
    horario,
    dia,
    diaId,
    turnoEntradaId,
    CONVERT(VARCHAR(8), horaEntrada, 108) AS horaEntrada,
    turnoSalidaId,
    CONVERT(VARCHAR(8), horaSalida, 108) AS horaSalida,
    tipoTurno,
    CASE WHEN bLibre = 1 THEN 'SI' ELSE 'NO' END AS diaLibre,
    conectadoDiaId,
    vigenciaInicio,
    vigenciaFin
  -- permiso,
  -- justificacion
  FROM TurnosEmparejados
  WHERE (turnoEntradaId IS NOT NULL OR bLibre = 1)
  ORDER BY diaId, horaEntrada;

END

GO


-- SELECT 
--   h.id,
--   v.tFechaFin,
--   v.tFechaInicio
-- FROM 
--   Horario h
--   INNER JOIN HorarioDias hd on h.id = hd.horarioId_fk
--   INNER JOIN Vigencia v on v.horarioDiasId_fk = hd.id
-- WHERE h.id = 1
-- GROUP BY h.id, v.tFechaFin, v.tFechaInicio

-- SELECT horarioDiasId_fk, tFechaInicio, tFechaFin FROM Vigencia

