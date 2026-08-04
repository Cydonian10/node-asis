IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_GetLicenciaById'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_GetLicenciaById];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetLicenciaById]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Obtener una licencia específica por ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetLicenciaById] @LICENCIAID INT
AS
BEGIN
    SELECT L.id
        , L.rolUsuarioId_fk
        , L.motivoId_fk
        , L.titulo
        , L.detalle
        , CONVERT(VARCHAR(10), L.tFechaInicio, 120) AS fechaInicio
        , CONVERT(VARCHAR(10), L.tFechaFin, 120) AS fechaFin
    FROM Licencia AS L
    INNER JOIN Motivo AS M
        ON M.id = L.motivoId_fk
    INNER JOIN RolUsuario AS RU
        ON RU.id = L.rolUsuarioId_fk
    WHERE L.id = @LICENCIAID
        AND L.bEliminado = 0
        AND M.bEliminado = 0
        AND RU.bEliminado = 0
END;
GO


