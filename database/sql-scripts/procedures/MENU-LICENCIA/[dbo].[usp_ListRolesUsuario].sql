IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_ListRolesUsuario'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_ListRolesUsuario];
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
CREATE PROCEDURE [dbo].[usp_ListRolesUsuario] @USUARIO_ID INT = NULL
    , @UNIDAD_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ru.id AS usuarioRolId
        , r.id AS rolId
        , r.cTitulo AS rol
        , r.bSupervision AS supervision
        , COALESCE(su.id, @USUARIO_ID) AS usuarioId
        , -- siempre devuelve algo
        CASE 
            WHEN ru.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS asignado
        , CASE 
            WHEN ru.id IS NOT NULL
                AND (
                    EXISTS (
                        SELECT 1
                        FROM Licencia AS L
                        WHERE L.rolUsuarioId_fk = RU.id
                            AND L.bEliminado = 0
                        )
                    OR EXISTS (
                        SELECT 1
                        FROM Permiso AS P
                        WHERE P.rolUsuarioId_fk = RU.id
                            AND P.bEliminado = 0
                        )
                    OR EXISTS (
                        SELECT 1
                        FROM Justificacion AS J
                        WHERE J.rolUsuarioId_fk = RU.id
                            AND J.bEliminado = 0
                        )
                    OR EXISTS (
                        SELECT 1
                        FROM ControlVacaciones AS CV
                        WHERE CV.rolUsuarioId_fk = RU.id
                            AND CV.bEliminado = 0
                        )
                    OR EXISTS (
                        SELECT 1
                        FROM ControlRolUsuario AS CRU
                        WHERE CRU.rolUsuarioId_fk = RU.id
                            AND CRU.bEliminado = 0
                        )
                    OR EXISTS (
                        SELECT 1
                        FROM Asistencia AS A
                        WHERE A.rolUsuarioid_fk = RU.id
                            AND A.bEliminado = 0
                        )
                    OR EXISTS (
                        SELECT 1
                        FROM HorarioUsuario AS HU
                        WHERE hu.rolUsuarioId_fk = ru.id
                            AND HU.bEliminado = 0
                        )
                    OR EXISTS (
                        SELECT 1
                        FROM TurnoModificado AS TM
                        WHERE tm.rolUsuarioId_fk = ru.id
                            AND TM.bEliminado = 0
                        )
                    )
                THEN 1
            ELSE 0
            END AS enUso
    FROM Rol AS R
    LEFT JOIN RolUsuario AS RU
        ON RU.rolId_fk = R.id
            AND RU.bEliminado = 0
    LEFT JOIN Sync_Usuario AS SU
        ON SU.id = RU.usuarioId_fk
    WHERE R.bEliminado = 0
        AND ru.bEliminado = 0
        AND (
            @UNIDAD_ID IS NULL
            OR R.unidadId_fk = @UNIDAD_ID
            )
        AND (
            @USUARIO_ID IS NULL
            OR RU.usuarioId_fk = @USUARIO_ID
            )
    ORDER BY asignado DESC;
END
GO


