/*======================================================================================================
NOMBRE: [dbo].[usp_GetAreaUsuarios]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Listar los usuarios de un area (Usuario JOIN SyncUsuarios JOIN UsuarioArea) con esSupervisor.
          Excluye usuarios con Eliminado = 1 (SPEC 04).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  1  13-08-2026  Gabriel    Modelo multi-area: JOIN UsuarioArea, agrega usuarioAreaId.
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetAreaUsuarios]
    -- Parametros de entrada
    @AreaId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.UsuarioId AS usuarioId,
        UA.UsuarioAreaId AS usuarioAreaId,
        SU.SyncUsuarioId AS syncUsuarioId,
        UA.AreaId AS areaId,
        UA.EsSupervisor AS esSupervisor,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos
    FROM Usuario U
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    INNER JOIN UsuarioArea UA ON UA.UsuarioId = U.UsuarioId AND UA.Eliminado = 0
    WHERE UA.AreaId = @AreaId
        AND U.Eliminado = 0;
END
GO
