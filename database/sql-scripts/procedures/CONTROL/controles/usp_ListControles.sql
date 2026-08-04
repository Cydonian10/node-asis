SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_ListControles]
FECHA: 18-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar controles

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
01   15-12-2025  FLUNA      Añadir bEliminado = 0 a subconsultas en Case
======================================================================================================*/
ALTER PROCEDURE [dbo].[usp_ListControles]
AS
BEGIN
    SELECT
        id as id,
        nTolerancia as tolerancia,
        nLimiteFalta as  limiteFalta,
        nLimiteMarcacion as limiteMarcacion,
        CASE 
        WHEN EXISTS (SELECT 1 FROM ControlUnidad cu WHERE cu.controlId_fk = co.id AND cu.bEliminado = 0)
          OR EXISTS (SELECT 1 FROM ControlRolUsuario cru WHERE cru.controlId_fk = co.id AND cru.bEliminado = 0)
          OR EXISTS (SELECT 1 FROM RolControl rc WHERE rc.controlId_fk = co.id AND rc.bEliminado = 0)
        THEN 1 
        ELSE 0 
    END AS enUso
    FROM CONTROLES co 
    WHERE 
        co.bEliminado = 0 
END
GO
