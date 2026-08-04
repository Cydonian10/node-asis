SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlesUnidad]
FECHA: 26-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar controles por unidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
 CREATE OR ALTER  PROCEDURE [dbo].[usp_GetControlesUnidad]
    @UNIDAD_ID INT = NULL
AS
BEGIN
    SELECT 
        cu.unidadId_fk AS unidadId,
        c.nLimiteFalta AS limiteFalta,
        c.nLimiteMarcacion AS limiteMarcacion,
        c.nTolerancia AS tolerancia
    FROM ControlUnidad cu
        INNER JOIN Controles c on c.Id = cu.controlId_fk
    WHERE 
        cu.bEliminado = 0 AND
        c.bEliminado = 0 AND
        (@UNIDAD_ID IS NULL OR cu.unidadId_fk = @UNIDAD_ID);
END
GO
