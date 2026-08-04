SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_ListFechaLimite]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar fecha limite

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_ListFechaLimite]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        fl.id,
        fl.tfechaInicio AS fechaInicio,
        fl.tfechaFin AS fechaFin,
        CASE 
            WHEN EXISTS (SELECT 1 FROM Vigencia v WHERE v.fechaLimiteId_pk = fl.id AND v.bEliminado = 0) 
            THEN 1 ELSE 0 
        END AS enUso
    FROM FechaLimite fl
    WHERE fl.bEliminado = 0
    ORDER BY fl.tfechaInicio DESC;
END
GO
