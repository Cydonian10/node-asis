/*======================================================================================================
NOMBRE: [dbo].[usp_GetUsuario]
FECHA: 13-08-2026
AUTOR: Gabriel
OBJETIVO: Listar un usuario migrado por su UsuarioId (JOIN SyncUsuarios + Usuario + Area + Unidad
          + SyncUnidad). Excluye Eliminado = 1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUsuario]
    -- Parametros de entrada
    @usuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.UsuarioId AS usuarioId,
        SU.SyncUsuarioId AS syncUsuarioId,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos,
        SU.Dni AS dni,
        SU.Tipo AS tipo,
        U.Active AS activo,
        U.AreaId AS areaId,
        A.Nombre AS areaNombre,
        A.UnidadId AS unidadId,
        SY.Nombre AS unidadNombre,
        U.EsSupervisor AS esSupervisor
    FROM Usuario U
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    INNER JOIN Area A ON A.AreaId = U.AreaId
    INNER JOIN Unidad UN ON UN.UnidadId = A.UnidadId
    INNER JOIN SyncUnidad SY ON SY.SyncUnidadId = UN.SyncUnidadId
    WHERE U.UsuarioId = @usuarioId
        AND U.Eliminado = 0
        AND A.Eliminado = 0;
END
GO
