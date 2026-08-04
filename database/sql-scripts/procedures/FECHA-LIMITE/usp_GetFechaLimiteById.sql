SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetFechaLimiteById]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener fecha limite por ID

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetFechaLimiteById]
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        fl.id,
        fl.tfechaInicio,
        fl.tfechaFin,
        fl.bEliminado,
        CASE 
            WHEN EXISTS (SELECT 1 FROM Vigencia v WHERE v.fechaLimiteId_pk = fl.id AND v.bEliminado = 0) 
            THEN 1 ELSE 0 
        END AS enUso
    FROM FechaLimite fl
    WHERE fl.bEliminado = 0
      AND fl.id = @Id
    ORDER BY fl.tfechaInicio DESC;
END
GO
