/*======================================================================================================
NOMBRE: [dbo].[usp_GetUnidadUsuarios]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Listar los usuarios de una unidad derivando por area (UsuarioArea JOIN Area con
          Area.UnidadId = @UnidadId) JOIN SyncUsuarios. Incluye esSupervisor.
          Excluye usuarios con Eliminado = 1 (SPEC 04).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  1  13-08-2026  Gabriel    Modelo multi-area: JOIN UsuarioArea, agrega usuarioAreaId.
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUnidadUsuarios]
    -- Parametros de entrada
    @UnidadId INT
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
    INNER JOIN Area A ON A.AreaId = UA.AreaId AND A.Eliminado = 0
    WHERE A.UnidadId = @UnidadId
        AND U.Eliminado = 0;
END
GO
