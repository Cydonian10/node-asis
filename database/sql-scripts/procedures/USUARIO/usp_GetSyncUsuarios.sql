/*======================================================================================================
NOMBRE: [dbo].[usp_GetSyncUsuarios]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Listar todos los registros de SyncUsuarios con indicador de migrado.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetSyncUsuarios]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SU.SyncUsuarioId AS syncUsuarioId,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos,
        SU.Dni AS dni,
        SU.Tipo AS tipo,
        CASE WHEN U.UsuarioId IS NULL THEN 0 ELSE 1 END AS migrado
    FROM SyncUsuarios SU
    LEFT JOIN Usuario U ON U.SyncUsuarioId = SU.SyncUsuarioId AND U.Eliminado = 0;
END
GO
