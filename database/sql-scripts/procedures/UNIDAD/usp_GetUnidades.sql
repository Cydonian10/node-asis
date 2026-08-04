IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_GetUnidades'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_GetUnidades]
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetUnidades]
FECHA: 21-11-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar unidades organizaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUnidades]
AS
BEGIN
    SELECT
        U.id AS unidadId,
        SU.id AS abreviacion,
        SU.cTitulo AS titulo
    FROM Sync_Unidad SU
      INNER JOIN Unidad U
        ON SU.id = U.unidadOrgId_fk AND U.bEliminado = 0
END
GO

