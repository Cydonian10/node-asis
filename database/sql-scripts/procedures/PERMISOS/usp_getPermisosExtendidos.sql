/*======================================================================================================
NOMBRE: [dbo].[usp_getPermisosExtendidos]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los registros de permisos extendidos

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getPermisosExtendidos]
  @TURNO_EXTENDIDO_ID INT,
  @FECHA DATE
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    p.id AS permisoId,
    p.tfecha AS fechaPermiso,
    p.tHoraSalida AS horaSalida,
    p.tHoraRetornoEstimado AS horaRetornoEstimado,
    p.tHoraRetornoReal AS horaRetornoReal,
    te.id AS turnoExtendidoId,
    te.horaInicio AS turnoExtendidoHoraInicio,
    p.motivoId_fk AS motivoId,
    m.nombre AS motivoNombre
  FROM
    Permiso p
    INNER JOIN
    PermisoTurnoExtendido pte ON pte.permisoId_pk = p.id
    INNER JOIN
    TurnoExtendido te ON te.id = pte.turnoExtendidoId_pk
    INNER JOIN
    Motivo m ON m.id = p.motivoId_fk
  WHERE
      te.id =  @TURNO_EXTENDIDO_ID AND p.tfecha = @FECHA AND p.bEliminado = 0;
END