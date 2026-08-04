SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlRoles]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar controles por rol

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
01   16-12-2025  fluna      Añadir nombre de rol y unidad
======================================================================================================*/
ALTER PROCEDURE [dbo].[usp_GetControlRoles]
    @ROL_CONTROL_ID INT
AS
BEGIN
    SELECT rc.id AS id
           , rc.rolId_fk AS rolId
        , R.cTitulo AS rol
        , SU.cTitulo AS unidad
        , c.nLimiteFalta AS limiteFalta
        , c.nLimiteMarcacion AS limiteMarcacion
        , c.nTolerancia AS tolerancia
        ,  CASE 
            WHEN EXISTS (SELECT 1 FROM RolControlAsistencia RCA WHERE RCA.rolControlId_fk = rc.id)
            THEN 1
        ELSE 0 
        END AS uso
    FROM RolControl rc
        INNER JOIN CONTROLES c ON c.Id = rc.controlId_fk
        INNER JOIN ROL R ON rc.rolId_fk = R.id
        INNER JOIN Unidad U ON R.unidadId_fk = U.id
        INNER JOIN Sync_Unidad SU on U.unidadOrgId_fk = SU.id
    WHERE rc.bEliminado = 0
        AND c.bEliminado = 0
        AND
        rc.controlId_fk = @ROL_CONTROL_ID;
END
GO
