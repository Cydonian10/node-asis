/*======================================================================================================
NOMBRE: [dbo].[usp_getMarcacionesExtendidasPorAsistenciaId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Reprocesar asistencia de usuarios en el sistema.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getMarcacionesExtendidasPorAsistenciaId]
  @ASISTENCIA_ID INT,
  @ROL_USUARIO_ID INT
AS
BEGIN
  SELECT
    a.id as asistenciaId,
    ae.id as asistenciaRegularId,
    a.horaEntrada,
    a.horaSalida,
    ae.marcacionId_fk,
    a.rolUsuarioid_fk,
    m.punch_time,
    ptr.permisoId_pk permisoTurnoExtendidoId,
    ptr.tCreatedAt permisoTurnoExtendidoFecha,
    jtr.justificacionId_fk justificacionTurnoExtendidoId,
    jtr.tCreatedAt justificacionTurnoExtendidoFecha
  FROM Asistencia a
    LEFT JOIN AsistenciaExtendida ae on a.id = ae.asistenciaId_fk AND ae.bEliminado = 0
    INNER JOIN Marcacion m on m.id = ae.marcacionId_fk AND m.bEliminado = 0
    LEFT JOIN JustificacionTurnoExtendido jtr on jtr.turnoExtendidoId_fk = ae.turnoExtendidoId_fk
    LEFT JOIN PermisoTurnoExtendido ptr on ptr.turnoExtendidoId_pk = ae.turnoExtendidoId_fk
  WHERE a.id =  @ASISTENCIA_ID AND rolUsuarioid_fk = @ROL_USUARIO_ID
    AND a.bEliminado = 0
END
GO

EXEC dbo.usp_getMarcacionesExtendidasPorAsistenciaId @ASISTENCIA_ID = 23, @ROL_USUARIO_ID = 1


--INSERT INTO AsistenciaExtendida WHERE id = 3
