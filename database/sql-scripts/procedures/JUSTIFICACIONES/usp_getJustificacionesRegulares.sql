/*======================================================================================================
NOMBRE: [dbo].[usp_getJustificacionesRegulares]
FECHA: 28/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los horarios de un usuario a partir de su RolUsuarioId y genear asistencia a partir
del horario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getJustificacionesRegulares]
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
    tr.id as turnoId,
    tr.horaInicio as horaInicioTurno
  FROM
    Justificacion j
    INNER JOIN JustificacionTurnoRegular jtr on jtr.justificacionId_fk = j.id and jtr.bEliminado = 0
    INNER JOIN TurnoRegular tr on tr.id = jtr.turnoRegularId_fk AND tr.bEliminado = 0
    INNER JOIN Motivo m on m.id = j.motivoId_fk and m.bEliminado = 0
  WHERE
      tr.id =  @TURNO_ID AND j.fecha = @FECHA AND j.bEliminado = 0;
END