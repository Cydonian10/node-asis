/*======================================================================================================
NOMBRE: [dbo].[usp_getPermisosRegulares]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los registros de permisos extendidos

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getPermisosRegulares]
  @TURNO_REGULAR_ID INT,
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
    tr.id AS turnoRegularId,
    tr.horaInicio AS turnoRegularHoraInicio,
    p.motivoId_fk AS motivoId,
    m.nombre AS motivoNombre
  FROM
    Permiso p
    INNER JOIN
    PermisoTurnoRegular ptr ON ptr.permisoId_pk = p.id
    INNER JOIN
    TurnoRegular tr ON tr.id = ptr.turnoRegularId_pk
    INNER JOIN
    Motivo m ON m.id = p.motivoId_fk
  WHERE
      tr.id =  @TURNO_REGULAR_ID AND p.tfecha = @FECHA AND p.bEliminado = 0;
END



