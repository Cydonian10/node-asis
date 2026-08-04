/*======================================================================================================
NOMBRE: [dbo].[usp_getJustificacionesExtendidos]
FECHA: 28/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los horarios de un usuario a partir de su RolUsuarioId y genear asistencia a partir
del horario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getJustificacionesExtendidos]
  @TURNO_ID INT,
  @FECHA DATE
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    j.id as justificacionId,
    j.fecha as fechaJustificacion,
    j.cDetalle as detalleJustificacion,
    j.motivoId_fk as motivoId,
    m.nombre as nombreMotivo,
    te.id as turnoId,
    te.horaInicio as horaInicioTurno
  FROM Justificacion j
    INNER JOIN JustificacionTurnoExtendido jte on jte.justificacionId_fk = j.id and jte.bEliminado = 0
    INNER JOIN TurnoExtendido te on te.id = jte.turnoExtendidoId_fk
    INNER JOIN Motivo m on m.id = j.motivoId_fk and m.bEliminado = 0
  WHERE
  te.id = @TURNO_ID and j.fecha = @FECHA and j.bEliminado = 0
END