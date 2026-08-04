/*======================================================================================================
NOMBRE: [dbo].[usp_GetAllRolUsuario]
FECHA: 20-01-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite listar todas los RolUsuario existentes por usuarioId.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetAllRolUsuario]
  @USUARIO_ID INT,
  @UNIDAD_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT RU.id
        , RU.usuarioId_fk AS usuarioId
        , U.cUsuario AS usuario
        , RU.rolId_fk AS rolId
        , R.cTitulo AS rol
  FROM RolUsuario AS RU
    INNER JOIN Rol AS R
    ON RU.rolId_fk = R.id
    INNER JOIN Sync_Usuario AS U
    ON RU.usuarioId_fk = U.id
  WHERE RU.usuarioId_fk = @USUARIO_ID AND R.unidadId_fk = @UNIDAD_ID AND RU.bEliminado = 0;

END