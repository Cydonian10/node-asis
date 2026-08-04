/*======================================================================================================
NOMBRE: [dbo].[usp_getAsistenciaId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener los datos de una asistencia por su Id, incluyendo permisos, justificaciones y turnos modificados.

MODIFICACIONES:
NRO  FECHA          USUARIO                      MODIFICACION
     
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getAsistenciaId]
  @FECHA DATE,
  @TURNO_ID INT,
  @ROL_USUARIO_ID INT,
  @ES_REGULAR BIT = 1
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    a.id asistenciaId
  FROM Asistencia a
  WHERE CAST(a.tFecha AS DATE) = @FECHA
    AND a.rolUsuarioId_fk = @ROL_USUARIO_ID
    AND a.turnoEntradaid = @TURNO_ID
    AND a.bEliminado = 0
    AND a.esRegular = @ES_REGULAR;
END

