/*======================================================================================================
NOMBRE: [dbo].[usp_GetUsuario]
FECHA: 13-08-2026
AUTOR: Gabriel
OBJETIVO: Listar los registros (usuario, area) de un usuario migrado por su UsuarioId. Devuelve UNA
          fila por area del usuario. Excluye Eliminado = 1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  1  13-08-2026  Gabriel    Modelo multi-area: JOIN UsuarioArea, agrega usuarioAreaId, una fila por area.
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUsuario]
    -- Parametros de entrada
    @usuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.UsuarioId AS usuarioId,
        UA.UsuarioAreaId AS usuarioAreaId,
        SU.SyncUsuarioId AS syncUsuarioId,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos,
        SU.Dni AS dni,
        SU.Tipo AS tipo,
        U.Active AS activo,
        UA.AreaId AS areaId,
        A.Nombre AS areaNombre,
        A.UnidadId AS unidadId,
        SY.Nombre AS unidadNombre,
        UA.EsSupervisor AS esSupervisor
    FROM Usuario U
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    INNER JOIN UsuarioArea UA ON UA.UsuarioId = U.UsuarioId AND UA.Eliminado = 0
    INNER JOIN Area A ON A.AreaId = UA.AreaId AND A.Eliminado = 0
    INNER JOIN Unidad UN ON UN.UnidadId = A.UnidadId
    INNER JOIN SyncUnidad SY ON SY.SyncUnidadId = UN.SyncUnidadId
    WHERE U.UsuarioId = @usuarioId
        AND U.Eliminado = 0;
END
GO
