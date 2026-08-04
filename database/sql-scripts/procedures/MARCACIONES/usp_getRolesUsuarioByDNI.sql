/*======================================================================================================
NOMBRE: [dbo].[usp_getRolesUsuarioByDNI]
FECHA: 20/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los roles y horarios de un usuario a partir de su DNI.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getRolesUsuarioByDNI]
  @DNI NVARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT su.id usuarioId, ru.id rolUsuarioId, r.cTitulo rol, hu.horarioId_fk horarioId
  FROM Sync_Usuario su
    INNER JOIN RolUsuario  ru on ru.usuarioId_fk = su.id and ru.bEliminado = 0
    INNER JOIN Rol r ON r.id = ru.rolId_fk AND r.bEliminado = 0
    INNER JOIN HorarioUsuario hu on hu.rolUsuarioId_fk = ru.id AND hu.bEliminado = 0
    inner JOIN Horario h on h.id = hu.horarioId_fk AND h.bEliminado = 0
  WHERE su.cDni = @DNI
END