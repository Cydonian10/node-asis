/*======================================================================================================
NOMBRE: [dbo].[usp_GetSyncUnidades]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Listar todos los registros de SyncUnidad con indicador de migrado.
          Se considera migrada la fila que tenga una Unidad asociada.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetSyncUnidades]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SU.SyncUnidadId AS syncUnidadId,
        SU.Codigo AS codigo,
        SU.Nombre AS nombre,
        CASE WHEN U.UnidadId IS NULL THEN 0 ELSE 1 END AS migrado
    FROM SyncUnidad SU
    LEFT JOIN Unidad U ON U.SyncUnidadId = SU.SyncUnidadId;
END
GO
