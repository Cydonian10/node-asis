IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_GetLicencia'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_GetLicencia];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetLicencia]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Obtener una licencia específica de todas las licencias.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetLicencia]
AS
BEGIN
    SELECT L.id
        , L.rolUsuarioId_fk AS rolUsuario
        , L.motivoId_fk AS motivoId
        , M.nombre
        , L.titulo
        , L.detalle
        , CONVERT(VARCHAR(10), L.tFechaInicio, 120) AS fechaInicio
        , CONVERT(VARCHAR(10), L.tFechaFin, 120) AS fechaFin
    FROM Licencia AS L
    INNER JOIN Motivo AS M
        ON M.id = L.motivoId_fk
    INNER JOIN RolUsuario AS RU
        ON RU.id = L.rolUsuarioId_fk
    WHERE L.bEliminado = 0
        AND M.bEliminado = 0
        AND RU.bEliminado = 0
END;
GO


