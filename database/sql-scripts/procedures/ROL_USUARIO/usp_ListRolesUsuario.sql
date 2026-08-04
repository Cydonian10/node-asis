IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_ListRolesUsuario'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_ListRolesUsuario]
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_ListRolesUsuario]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar roles de un usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_ListRolesUsuario]
    @ROL_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RU.id AS usuarioRolId
        , RU.usuarioId_fk AS usuarioId
        , RU.rolId_fk AS rolId
        , R.cTitulo AS rol
        , R.bSupervision AS supervision
        , CASE WHEN RU.id IS NOT NULL THEN 1 ELSE 0 END AS asignado 
        , CASE 
            WHEN
                -- Verifica si el rolUsuario está en uso
                EXISTS (
                    SELECT 1
            FROM Licencia L
            WHERE L.rolUsuarioId_fk = RU.id
                AND L.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM Permiso P
            WHERE P.rolUsuarioId_fk = RU.id
                AND P.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM Justificacion J
            WHERE J.rolUsuarioId_fk = RU.id
                AND J.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM ControlVacaciones CV
            WHERE CV.rolUsuarioId_fk = RU.id
                AND CV.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM ControlRolUsuario CRU
            WHERE CRU.rolUsuarioId_fk = RU.id
                AND CRU.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM Asistencia A
            WHERE A.rolUsuarioid_fk = RU.id
                AND A.bEliminado = 0
                    )
                THEN 1
            ELSE 0
            END AS EnUso
        , CONCAT(U.cNombre,' ',U.cApellido) AS usuario
    FROM RolUsuario AS RU
        INNER JOIN Rol AS R
        ON RU.rolId_fk = R.id
            AND R.bEliminado = 0
        INNER JOIN Sync_Usuario AS U
        ON RU.usuarioId_fk = U.id
    WHERE RU.bEliminado = 0
        AND RU.rolId_fk = @ROL_ID
    ORDER BY RU.id;
END;
GO
