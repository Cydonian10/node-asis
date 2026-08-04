/*======================================================================================================
NOMBRE: [dbo].[usp_getMarcacionesPorAsistenciaId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Reprocesar asistencia de usuarios en el sistema.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_getMarcacionesPorAsistenciaId]
  @ASISTENCIA_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Consulta principal: Asistencia Regular
  IF EXISTS (
    SELECT 1
  FROM Asistencia a
    LEFT JOIN AsistenciaRegular ar ON a.id = ar.asistenciaId_fk AND ar.bEliminado = 0
    INNER JOIN Marcacion m ON m.id = ar.marcacionId_fk AND m.bEliminado = 0
  WHERE a.id = @ASISTENCIA_ID AND a.bEliminado = 0
  )
  BEGIN
    SELECT
      a.id as asistenciaId,
      ar.id as asistenciaRegularId,
      a.horaEntrada,
      a.horaSalida,
      ar.marcacionId_fk,
      a.rolUsuarioId_fk,
      m.punch_time,
      -- ptr.permisoId_pk permisoTurnoRegularId,
      -- ptr.tCreatedAt permisoTurnoRegularFecha,
      -- jtr.justificacionId_fk justificacionTurnoRegularId,
      -- jtr.tCreatedAt justificacionTurnoRegularFecha,
      -- tm.tHora turnoModificadoHora,
      -- tm.id turnoModificadoId,
      -- CASE 
      --   WHEN tm.btipo = 1 THEN 'SALIDA'
      --   WHEN tm.btipo = 0 THEN 'ENTRADA'
      --   ELSE NULL
      -- END AS turnoModificadoTipo,
      'regular' AS tipoAsistencia,
      null diaConectado,
      m.terminal_alias status
    FROM Asistencia a
      LEFT JOIN AsistenciaRegular ar ON a.id = ar.asistenciaId_fk AND ar.bEliminado = 0
      INNER JOIN Marcacion m ON m.id = ar.marcacionId_fk AND m.bEliminado = 0
      -- LEFT JOIN TurnoModificado tm ON tm.turnoRegularId_fk = ar.turnoRegularId_fk AND tm.bEliminado = 0
      -- LEFT JOIN JustificacionTurnoRegular jtr ON jtr.turnoRegularId_fk = ar.turnoRegularId_fk
      -- LEFT JOIN PermisoTurnoRegular ptr ON ptr.turnoRegularId_pk = ar.turnoRegularId_fk
    WHERE a.id = @ASISTENCIA_ID
      AND a.bEliminado = 0
  END
  ELSE
  BEGIN
    -- Consulta alternativa: Asistencia Extendida
    SELECT
      a.id as asistenciaId,
      ae.id as asistenciaRegularId,
      a.horaEntrada,
      a.horaSalida,
      ae.marcacionId_fk,
      a.rolUsuarioid_fk,
      m.punch_time,
      -- ptr.permisoId_pk permisoTurnoExtendidoId,
      -- ptr.tCreatedAt permisoTurnoExtendidoFecha,
      -- jtr.justificacionId_fk justificacionTurnoExtendidoId,
      -- jtr.tCreatedAt justificacionTurnoExtendidoFecha,
      NULL as turnoModificadoHora,
      NULL as turnoModificadoId,
      NULL as turnoModificadoTipo,
      'extendida' AS tipoAsistencia,
      -- d.cTitulo diaConectado,
      m.terminal_alias status
    FROM Asistencia a
      LEFT JOIN AsistenciaExtendida ae ON a.id = ae.asistenciaId_fk AND ae.bEliminado = 0
      INNER JOIN Marcacion m ON m.id = ae.marcacionId_fk AND m.bEliminado = 0
      -- LEFT JOIN JustificacionTurnoExtendido jtr ON jtr.turnoExtendidoId_fk = ae.turnoExtendidoId_fk
      -- LEFT JOIN PermisoTurnoExtendido ptr ON ptr.turnoExtendidoId_pk = ae.turnoExtendidoId_fk
      -- LEFT JOIN ConectadoDias cd ON cd.turnoExtendidoId_pk = ae.turnoExtendidoId_fk
      -- INNER JOIN Dia d ON d.id = cd.diasId_pk AND d.bEliminado = 0
    WHERE a.id = @ASISTENCIA_ID
      AND a.bEliminado = 0
  END
END
GO



