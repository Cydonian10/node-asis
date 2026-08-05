/*======================================================================================================
NOMBRE: [dbo].[usp_GetAreaUsuarios]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Listar los usuarios de un area (Usuario JOIN SyncUsuarios) con esSupervisor.
          Excluye usuarios con Eliminado = 1 (SPEC 04).

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
        U.UsuarioId AS usuarioId,
        SU.SyncUsuarioId AS syncUsuarioId,
        U.AreaId AS areaId,
        U.EsSupervisor AS esSupervisor,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos
    FROM Usuario U
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    WHERE U.AreaId = @AreaId
        AND U.Eliminado = 0;
END
GO
