/*======================================================================================================
NOMBRE: [dbo].[usp_GetMarcaciones]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener las marcaciones regulares para una unidad y rango de fechas.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetMarcaciones]
  @UNIDAD_ID INT,
  @FECHA_INICIO DATE,
  @FECHA_FIN DATE,
  @USUARIO VARCHAR(100) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- Marcaciones Regulares
      SELECT
      a.id asistenciaId,
      su.cNombre + ' ' + su.cApellido AS nombreCompleto,
      m.punch_time AS horaMarcacion,
      ru.id AS rolUsuarioId,
      m.terminal_alias,
      'regular' AS tipoAsistencia,
      CASE
        WHEN cua.asistenciaId_fk IS NOT NULL
        OR rca.asistenciaId_fk IS NOT NULL
        OR crua.asistenciaId_fk IS NOT NULL
        THEN 'procesado'
        ELSE 'no procesado'
      END AS estadoProcesado,
      CASE
        WHEN ea1.cNombre IS NOT NULL THEN ea1.cNombre
        WHEN ea2.cNombre IS NOT NULL THEN ea2.cNombre
        WHEN ea3.cNombre IS NOT NULL THEN ea3.cNombre
        ELSE 'NO_PROCESADO'
      END AS codigoEstadoProcesado,
      a.horaEntrada,
      a.horaSalida
    FROM Asistencia a
      INNER JOIN AsistenciaRegular ar on ar.asistenciaId_fk = a.id and ar.bEliminado = 0
      INNER JOIN Marcacion m on m.id = ar.marcacionId_fk and m.bEliminado = 0
      INNER JOIN RolUsuario ru on ru.id = a.rolUsuarioid_fk and ru.bEliminado = 0
      INNER JOIN Rol r on r.id = ru.rolId_fk and r.bEliminado = 0 and r.unidadId_fk = @UNIDAD_ID
      INNER JOIN Sync_Usuario su on su.id = ru.usuarioId_fk
      LEFT JOIN ControlUnidadAsistencia cua ON cua.asistenciaId_fk = a.id AND cua.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea1 on ea1.id = cua.estadoAsistenciaId_fk and ea1.bEliminado = 0
      LEFT JOIN RolControlAsistencia rca ON rca.asistenciaId_fk = a.id AND rca.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea2 on ea2.id = rca.estadoAsistenciaId_fk and ea2.bEliminado = 0
      LEFT JOIN ControlRolUsuarioAsistencia crua ON crua.asistenciaId_fk = a.id AND crua.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea3 on ea3.id = crua.estadoAsistenciaId_fk and ea3.bEliminado = 0
    WHERE CONVERT(DATE, a.tFecha) BETWEEN @FECHA_INICIO AND @FECHA_FIN
      AND ( @USUARIO IS NULL OR su.cUsuario LIKE '%' + @USUARIO + '%' )

  UNION ALL

    -- Marcaciones Extendidas
    SELECT
      a.id asistenciaId,
      su.cNombre + ' ' + su.cApellido AS nombreCompleto,
      m.punch_time AS horaMarcacion,
      ru.id AS rolUsuarioId,
      m.terminal_alias,
      'extendida' AS tipoAsistencia,
      CASE
        WHEN cua.asistenciaId_fk IS NOT NULL
        OR rca.asistenciaId_fk IS NOT NULL
        OR crua.asistenciaId_fk IS NOT NULL
        THEN 'procesado'
        ELSE 'no procesado'
      END AS estadoProcesado,
      CASE
        WHEN ea1.cNombre IS NOT NULL THEN ea1.cNombre
        WHEN ea2.cNombre IS NOT NULL THEN ea2.cNombre
        WHEN ea3.cNombre IS NOT NULL THEN ea3.cNombre
        ELSE 'NO_PROCESADO'
      END AS codigoEstadoProcesado,
      a.horaEntrada,
      a.horaSalida
    FROM Asistencia a
      INNER JOIN AsistenciaExtendida ae on ae.asistenciaId_fk = a.id and ae.bEliminado = 0
      INNER JOIN Marcacion m on m.id = ae.marcacionId_fk and m.bEliminado = 0
      INNER JOIN RolUsuario ru on ru.id = a.rolUsuarioid_fk and ru.bEliminado = 0
      INNER JOIN Rol r on r.id = ru.rolId_fk and r.bEliminado = 0 and r.unidadId_fk = @UNIDAD_ID
      INNER JOIN Sync_Usuario su on su.id = ru.usuarioId_fk
      LEFT JOIN ControlUnidadAsistencia cua ON cua.asistenciaId_fk = a.id AND cua.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea1 on ea1.id = cua.estadoAsistenciaId_fk and ea1.bEliminado = 0
      LEFT JOIN RolControlAsistencia rca ON rca.asistenciaId_fk = a.id AND rca.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea2 on ea2.id = rca.estadoAsistenciaId_fk and ea2.bEliminado = 0
      LEFT JOIN ControlRolUsuarioAsistencia crua ON crua.asistenciaId_fk = a.id AND crua.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea3 on ea3.id = crua.estadoAsistenciaId_fk and ea3.bEliminado = 0
    WHERE CONVERT(DATE, a.tFecha) BETWEEN @FECHA_INICIO AND @FECHA_FIN
      AND ( @USUARIO IS NULL OR su.cUsuario LIKE '%' + @USUARIO + '%' )

  ORDER BY horaMarcacion DESC
END



