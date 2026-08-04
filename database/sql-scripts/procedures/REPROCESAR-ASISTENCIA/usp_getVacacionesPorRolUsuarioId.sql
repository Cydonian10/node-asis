/*======================================================================================================
NOMBRE: [dbo].[usp_getVacacionesPorRolUsuarioId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar o actualizar el control de rol de usuario para la asistencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getVacacionesPorRolUsuarioId]
  @ROL_USUARIO_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT pv.fechaInicio, pv.fechaFin, cv.rolUsuarioId_fk as rolUsuarioId, cv.id controlId
  FROM PeriodoVacacional pv
    INNER JOIN ControlVacaciones cv on cv.id = pv.controlVacacionalId_fk
  WHERE cv.rolUsuarioId_fk = @ROL_USUARIO_ID AND YEAR(pv.fechaInicio) = YEAR(GETDATE()) AND (MONTH(pv.fechaInicio) = month(GETDATE()) OR MONTH(pv.fechaFin) = month(GETDATE()));
END
 