SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_ListUnidadesOrganizativas]
FECHA: 17-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar unidades organizativas que no esta relacionada un control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 
======================================================================================================*/
ALTER PROCEDURE [dbo].[usp_ListUnidadesOrganizativas]
    @CONTROLID INT
AS
BEGIN
    SELECT
        u.id,
        u.horaTotal,
        u.horaEstandar,
        su.cTitulo as unidad,
        CASE 
            WHEN 
             EXISTS (SELECT 1
            FROM Supervisor s
            WHERE s.unidadId_pk = u.id AND s.bEliminado = 0)
            OR EXISTS (SELECT 1
            FROM Rol r
            WHERE r.unidadId_fk = u.id AND r.bEliminado = 0)
            OR EXISTS (SELECT 1
            FROM UnidadFeriado uf
            WHERE uf.unidadId_pk = u.id)
        THEN 1 
        ELSE 0 
    END AS enUso
    FROM Unidad u
        INNER JOIN Sync_Unidad su on su.id = u.unidadOrgId_fk
    WHERE 
     NOT EXISTS (
        SELECT 1
    FROM ControlUnidad CU
    WHERE 
        CU.unidadId_fk = u.id
        AND CU.controlId_fk = @CONTROLID
        AND CU.bEliminado = 0
    );
END
GO
