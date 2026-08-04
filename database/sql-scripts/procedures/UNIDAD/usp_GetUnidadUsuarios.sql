/*======================================================================================================
NOMBRE: [dbo].[usp_GetUnidadUsuarios]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Listar los usuarios asignados a una unidad (UsuarioUnidad JOIN Usuario + SyncUsuarios).
          Excluye las asignaciones y usuarios con Eliminado = 1.

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
        UU.UsuarioUnidadId AS usuarioUnidadId,
        UU.UsuarioId AS usuarioId,
        UU.UnidadId AS unidadId,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos
    FROM UsuarioUnidad UU
    INNER JOIN Usuario U ON U.UsuarioId = UU.UsuarioId
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    WHERE UU.UnidadId = @UnidadId
        AND UU.Eliminado = 0
        AND U.Eliminado = 0;
END
GO
