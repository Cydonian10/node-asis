/*======================================================================================================
NOMBRE: [dbo].[usp_ListUnidad]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar unidades

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 01  24/11/2025  FLUNA      Se ñadio bEliminado=0 en CASE
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_ListUnidad]
@USER INT
AS
BEGIN
    SELECT
        u.id,
        u.horaTotal,
        u.horaEstandar,
        su.cTitulo as unidad,
        CASE 
            WHEN EXISTS (SELECT 1 FROM ControlUnidad cu WHERE cu.unidadId_fk = u.id AND cu.bEliminado = 0)
            OR EXISTS (SELECT 1 FROM Supervisor s WHERE s.unidadId_pk = u.id AND s.bEliminado = 0)
            OR EXISTS (SELECT 1 FROM Rol r WHERE r.unidadId_fk = u.id AND r.bEliminado = 0)
            OR EXISTS (SELECT 1 FROM UnidadFeriado uf WHERE uf.unidadId_pk = u.id )
        THEN 1 
        ELSE 0 
    END AS enUso
    FROM Unidad u
        INNER JOIN Sync_Unidad su on su.id = u.unidadOrgId_fk 
        LEFT JOIN Supervisor sp on sp.unidadId_pk = u.id
    WHERE sp.usuarioId_pk = @USER AND u.bEliminado = 0
END
GO
