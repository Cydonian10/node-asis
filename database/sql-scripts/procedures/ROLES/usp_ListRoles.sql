/*======================================================================================================
NOMBRE: [dbo].[usp_ListRoles]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar roles con filtros opcionales

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_ListRoles]
    @UNIDAD_ID INT = NULL
AS
BEGIN
    SELECT
        r.id as id,
        r.cTitulo as titulo,
        r.cDescripcion as descripcion,
        r.bSupervision as supervicion,
        CASE 
            WHEN EXISTS (SELECT 1 FROM RolControl rc WHERE rc.rolId_fk = r.id)
            OR EXISTS (SELECT 1 FROM RolUsuario ru WHERE ru.rolId_fk = r.id)
            THEN 1
        ELSE 0
    END AS enUso
    FROM Rol r
    WHERE 
        r.bEliminado = 0 AND
        r.unidadId_fk = COALESCE(@UNIDAD_ID, unidadId_fk)
END
GO
