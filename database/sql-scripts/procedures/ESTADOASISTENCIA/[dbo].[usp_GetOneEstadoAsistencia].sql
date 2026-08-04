IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_GetOneEstadoAsistencia'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_GetOneEstadoAsistencia];
GO

/*=================================================================================
Nombre: [dbo].[usp_GetOneEstadoAsistencia]
Autor: Jesamine Ramon Yora
Fecha: 09-10-2025
Descripcion: Procedimiento para mostrar un registro a partir del ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
--=================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetOneEstadoAsistencia] @ID INT
AS
BEGIN
    SELECT EA.id
        , EA.cNombre AS nombre
        , CASE 
            WHEN CRUA.id IS NOT NULL
                OR CUA.id IS NOT NULL
                OR RCA.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS USO
    FROM EstadoAsistencia EA
    LEFT JOIN ControlRolUsuarioAsistencia CRUA
        ON EA.id = CRUA.estadoAsistenciaId_fk
            AND CRUA.bEliminado = 0
    LEFT JOIN ControlUnidadAsistencia CUA
        ON EA.id = CUA.estadoAsistenciaId_fk
            AND CUA.bEliminado = 0
    LEFT JOIN RolControlAsistencia RCA
        ON EA.id = RCA.estadoAsistenciaId_fk
            AND RCA.bEliminado = 0
    WHERE EA.id = @ID
        AND EA.bEliminado = 0
    GROUP BY EA.id
        , EA.cNombre
        , CRUA.id
        , CUA.id
        , RCA.id;
END
GO


