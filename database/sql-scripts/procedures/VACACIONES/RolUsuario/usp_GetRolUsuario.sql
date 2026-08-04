SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetRolUsuario]
FECHA: 15-10-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite listar todas los RolUsuario existentes.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetRolUsuario]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RU.id
<<<<<<< Updated upstream:database/sql-scripts/procedures/VACACIONES/RolUsuario/usp_GetRolUsuario.sql
        , RU.usuarioId_fk AS usuarioId
        , U.cUsuario AS usuario
=======
        , RU.usuarioId_fk
        , U.cUsuario AS usuario
        , U.cNombre AS nombre
        , U.cApellido AS apellido
>>>>>>> Stashed changes:database/sql-scripts/procedures/VACACIONES/RolUsuario/usp_GetRolUsuario
        , RU.rolId_fk AS rolId
        , R.cTitulo AS rol
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
            END AS uso
    FROM RolUsuario AS RU
        INNER JOIN Rol AS R
        ON RU.rolId_fk = R.id
            AND R.bEliminado = 0
        INNER JOIN Sync_Usuario AS U
        ON RU.usuarioId_fk = U.id
    WHERE RU.bEliminado = 0
    ORDER BY RU.id;
END;
GO

