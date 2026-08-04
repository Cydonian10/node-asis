SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_ListUnidadesByControl]
FECHA: 12-12-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar las unidades segun el control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER PROCEDURE [dbo].[usp_ListUnidadesByControl]
    @CONTROLID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CU.id AS id,
        CU.controlId_fk AS controlId,
        U.unidadOrgId_fk AS unidadId,
        SU.cTitulo AS unidad,
        CASE 
    WHEN
    EXISTS(SELECT 1
        FROM ControlUnidadAsistencia CUA
        WHERE CUA.controlUnidadId_fk = CU.id AND CUA.bEliminado=0)
    THEN 1
    ELSE 0
    END AS enUso

    FROM ControlUnidad CU
        INNER JOIN Unidad U on U.id = CU.unidadId_fk
        INNER JOIN Sync_Unidad SU on SU.id = U.unidadOrgId_fk
    WHERE 
        CU.controlId_fk = @CONTROLID
        AND CU.bEliminado = 0
END;
GO
