IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_GetLicenciaByMotivoId'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_GetLicenciaByMotivoId];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetLicenciaByMotivoId]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Obtener una licencia específica por ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetLicenciaByMotivoId] @MOTIVOID INT
AS
BEGIN
    SELECT L.motivoId_fk AS motivoId
        , L.id AS licenciaId
        , L.rolUsuarioId_fk AS rolUsuario
        , M.nombre
        , M.detalle AS detalleMotivo
        , L.titulo
        , L.detalle AS detalleLicencia
        , CONVERT(VARCHAR(10), L.tFechaInicio, 120) AS fechaInicio
        , CONVERT(VARCHAR(10), L.tFechaFin, 120) AS fechaFin
    FROM Licencia AS L
    INNER JOIN Motivo AS M
        ON M.id = L.motivoId_fk
    INNER JOIN RolUsuario AS RU
        ON RU.id = L.rolUsuarioId_fk
    WHERE L.motivoId_fk = @MOTIVOID
        AND L.bEliminado = 0
        AND M.bEliminado = 0
        AND RU.bEliminado = 0
END;
GO


