/*======================================================================================================
NOMBRE: [dbo].[usp_GetUnidadUsuarios]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Listar los usuarios de una unidad derivando por area (Usuario JOIN Area con
          Area.UnidadId = @UnidadId) JOIN SyncUsuarios. Incluye esSupervisor.
          Excluye usuarios con Eliminado = 1 (SPEC 04).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUnidadUsuarios]
    -- Parametros de entrada
    @UnidadId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.UsuarioId AS usuarioId,
        SU.SyncUsuarioId AS syncUsuarioId,
        U.AreaId AS areaId,
        U.EsSupervisor AS esSupervisor,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos
    FROM Usuario U
    INNER JOIN Area A ON A.AreaId = U.AreaId
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    WHERE A.UnidadId = @UnidadId
        AND U.Eliminado = 0
        AND A.Eliminado = 0;
END
GO
