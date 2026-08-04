/*======================================================================================================
NOMBRE: [dbo].[usp_GetRolUsuarioById]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar rol de usuario por Id

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetRolUsuarioById]
    @ROL_USUARIO_ID INT 
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ru.id AS usuarioRolId,
        r.id AS rolId,
        r.cTitulo AS rol,
        r.bSupervision AS supervision,
        su.id AS usuarioId,
        CASE 
            WHEN ru.id IS NOT NULL THEN 1 
            ELSE 0 
        END AS asignado,
        CASE 
            WHEN ru.id IS NOT NULL AND (
                   EXISTS (SELECT 1 FROM ControlVacaciones cv WHERE cv.rolUsuarioId_fk = ru.id)
                OR EXISTS (SELECT 1 FROM HorarioUsuario hu WHERE hu.rolUsuarioId_fk = ru.id)
                OR EXISTS (SELECT 1 FROM TurnoModificado tm WHERE tm.rolUsuarioId_fk = ru.id)
                OR EXISTS (SELECT 1 FROM Licencia li WHERE li.rolUsuarioId_fk = ru.id)
                OR EXISTS (SELECT 1 FROM Permiso pe WHERE pe.rolUsuarioId_fk = ru.id)
            )
            THEN 1
            ELSE 0
        END AS enUso
    FROM Rol r
        inner JOIN RolUsuario ru
            ON ru.rolId_fk = r.id
           AND ru.bEliminado = 0
        inner JOIN Sync_Usuario su on su.id = ru.usuarioId_fk
            
    WHERE 
        r.bEliminado = 0
        AND ru.bEliminado = 0
        AND ru.id = @ROL_USUARIO_ID
    ORDER BY asignado DESC;
END
GO


