/*======================================================================================================
NOMBRE: [dbo].[usp_GetRolUnidadUsuarios]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Listar los usuarios con un rol-en-unidad (UsuarioRol JOIN RolUnidad + Rol + SyncUsuarios).
          Excluye Eliminado = 1 en las tablas con flag.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetRolUnidadUsuarios]
    -- Parametros de entrada
    @RolUnidadId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UR.UsuarioRolId AS usuarioRolId,
        UR.UsuarioId AS usuarioId,
        UR.RolUnidadId AS rolUnidadId,
        RU.RolId AS rolId,
        R.Nombre AS rolNombre,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos
    FROM UsuarioRol UR
    INNER JOIN RolUnidad RU ON RU.RolUnidadId = UR.RolUnidadId
    INNER JOIN Rol R ON R.RolId = RU.RolId
    INNER JOIN Usuario U ON U.UsuarioId = UR.UsuarioId
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    WHERE UR.RolUnidadId = @RolUnidadId
        AND UR.Eliminado = 0
        AND RU.Eliminado = 0
        AND U.Eliminado = 0;
END
GO
