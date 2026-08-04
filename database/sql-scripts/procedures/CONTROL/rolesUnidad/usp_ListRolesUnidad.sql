SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_ListRolesUnidad]
FECHA: 16-12-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar roles por unidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER PROCEDURE [dbo].[usp_ListRolesUnidad]
@CONTROLID INT
AS
BEGIN
    SELECT
        r.id as id,
        r.cTitulo as titulo,
        r.cDescripcion as descripcion,
        r.bSupervision as supervicion,
        r.unidadId_fk as idunidad,
        SU.cTitulo as unidad,
        CASE 
            WHEN EXISTS (SELECT 1 FROM RolControl rc WHERE rc.rolId_fk = r.id)
            OR EXISTS (SELECT 1 FROM RolUsuario ru WHERE ru.rolId_fk = r.id)
            THEN 1
        ELSE 0
    END AS enUso
    FROM Rol r
    INNER JOIN Unidad U ON r.unidadId_fk = U.id
    INNER JOIN Sync_Unidad SU ON U.unidadOrgId_fk = SU.id
    WHERE 
        -- r.bEliminado = 0
          NOT EXISTS (
        SELECT 1
    FROM RolControl RC
    WHERE 
        -- CU.unidadId_fk = u.id
        RC.rolId_fk = r.id
        AND RC.controlId_fk = @CONTROLID
        AND RC.bEliminado = 0
    );
END
GO
