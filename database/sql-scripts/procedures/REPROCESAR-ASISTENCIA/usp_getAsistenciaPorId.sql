/*======================================================================================================
NOMBRE: [dbo].[usp_getAsistenciasPorId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener los datos de una asistencia por su Id, incluyendo permisos, justificaciones y turnos modificados.

MODIFICACIONES:
NRO  FECHA          USUARIO                      MODIFICACION
 1   26-01-2026     Gabriel Vásquez Uscuvilca    Se agregó verificación de permisos, justificaciones y turnos modificados
 2   27-01-2026     Gabriel Vásquez Uscuvilca    Se cambió a devolver listas de permisos y justificaciones con sus turnos
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getAsistenciasPorId]
  @ASISTENCIA_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @FECHA DATE;
  DECLARE @ROL_USUARIO_ID INT;

  -- Obtener la fecha y rolUsuarioId de la asistencia
  SELECT
    @FECHA = CAST(tFecha AS DATE),
    @ROL_USUARIO_ID = rolUsuarioId_fk
  FROM Asistencia
  WHERE id = @ASISTENCIA_ID AND bEliminado = 0;

  -- Si no existe la asistencia, retornar vacío
  IF @FECHA IS NULL
  BEGIN
    SELECT
      NULL AS id,
      NULL AS fecha,
      NULL AS rolUsuarioId,
      NULL AS horaEntrada,
      NULL AS horaSalida,
      NULL AS vigenciaInicio,
      NULL AS vigenciaFin,
      NULL AS turnoEntradaId,
      NULL AS turnoSalidaId,
      NULL AS esRegular,
      NULL AS tieneTurnoModificado,
      NULL AS turnoModificadoId,
      NULL AS turnoModificadoHora,
      NULL AS turnoModificadoTipo,
      NULL AS permisos,
      NULL AS justificaciones;

    RETURN;
  END

  -- PRIMER RESULTSET: Datos de asistencia con arrays JSON de permisos y justificaciones
  SELECT
    a.id,
    a.tFecha AS fecha,
    a.rolUsuarioid_fk AS rolUsuarioId,
    a.horaEntrada,
    a.horaSalida,
    a.vigenciaInicio,
    a.vigenciaFin,
    a.turnoEntradaId,
    a.turnoSalidaId,
    a.esRegular,

    -- Verificación de Turno Modificado
    CASE 
      WHEN EXISTS (
        SELECT 1
    FROM TurnoModificado tm
    WHERE tm.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND @FECHA BETWEEN tm.fechaInicio AND tm.fechaFin
      AND tm.bEliminado = 0
      ) THEN 1 
      ELSE 0 
    END AS tieneTurnoModificado,

    (SELECT TOP 1
      tm.id
    FROM TurnoModificado tm
    WHERE tm.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND @FECHA BETWEEN tm.fechaInicio AND tm.fechaFin
      AND tm.bEliminado = 0
    ) AS turnoModificadoId,

    (SELECT TOP 1
      tm.tHora
    FROM TurnoModificado tm
    WHERE tm.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND @FECHA BETWEEN tm.fechaInicio AND tm.fechaFin
      AND tm.bEliminado = 0
    ) AS turnoModificadoHora,

    (SELECT TOP 1
      tm.btipo
    FROM TurnoModificado tm
    WHERE tm.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND @FECHA BETWEEN tm.fechaInicio AND tm.fechaFin
      AND tm.bEliminado = 0
    ) AS turnoModificadoTipo,

    -- Array JSON de permisos con sus turnos
    (
      SELECT
      p.id AS permisoId,
      COALESCE(ptr.turnoRegularId_pk, pte.turnoExtendidoId_pk) AS turnoId,
      CASE WHEN pte.permisoId_pk IS NOT NULL THEN 1 ELSE 0 END AS esExtendido
    FROM Permiso p
      LEFT JOIN PermisoTurnoRegular ptr ON p.id = ptr.permisoId_pk
      LEFT JOIN PermisoTurnoExtendido pte ON p.id = pte.permisoId_pk
    WHERE p.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND p.tfecha = @FECHA
      AND p.bEliminado = 0
      AND (ptr.turnoRegularId_pk IS NOT NULL OR pte.turnoExtendidoId_pk IS NOT NULL)
    FOR JSON PATH
    ) AS permisos,

    -- Array JSON de justificaciones con sus turnos
    (
      SELECT
      j.id AS justificacionId,
      COALESCE(jtr.turnoRegularId_fk, jte.turnoExtendidoId_fk) AS turnoId,
      CASE WHEN jte.justificacionId_fk IS NOT NULL THEN 1 ELSE 0 END AS esExtendido
    FROM Justificacion j
      LEFT JOIN JustificacionTurnoRegular jtr ON j.id = jtr.justificacionId_fk
      LEFT JOIN JustificacionTurnoExtendido jte ON j.id = jte.justificacionId_fk
    WHERE j.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND j.fecha = @FECHA
      AND j.bEliminado = 0
      AND (jtr.turnoRegularId_fk IS NOT NULL OR jte.turnoExtendidoId_fk IS NOT NULL)
    FOR JSON PATH
    ) AS justificaciones

  FROM Asistencia a
  WHERE a.id = @ASISTENCIA_ID AND a.bEliminado = 0;
END

GO

