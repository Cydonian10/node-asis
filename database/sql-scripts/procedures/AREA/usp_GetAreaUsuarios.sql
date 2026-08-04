/*======================================================================================================
NOMBRE: [dbo].[usp_GetAreaUsuarios]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Listar los usuarios asignados a un area (UsuarioArea JOIN Usuario + SyncUsuarios).
          Excluye las asignaciones y usuarios con Eliminado = 1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetAreaUsuarios]
    -- Parametros de entrada
    @AreaId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UA.UsuarioAreaId AS usuarioAreaId,
        UA.UsuarioId AS usuarioId,
        UA.AreaId AS areaId,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos
    FROM UsuarioArea UA
    INNER JOIN Usuario U ON U.UsuarioId = UA.UsuarioId
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    WHERE UA.AreaId = @AreaId
        AND UA.Eliminado = 0
        AND U.Eliminado = 0;
END
GO
