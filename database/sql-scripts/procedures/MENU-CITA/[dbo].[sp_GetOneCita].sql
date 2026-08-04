IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'sp_GetOneCita'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[sp_GetOneCita];
GO

/*======================================================================================================
NOMBRE: [dbo].[sp_GetOneCita]
FECHA: 26-09-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: Procedimiento para mostrar una cita por ID

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[sp_GetOneCita] @ID INT
AS
BEGIN
    SELECT c.id
        , hu.id
        , h.cTitulo
        , u.cUsuario
        , c.nombre
        , r.cTitulo
        , c.cDescripcion
        , CONVERT(VARCHAR(10), c.fecha, 120) AS fecha
        , hora
        , bCancelado = CASE 
            WHEN bCancelado = 1
                THEN 'SI'
            WHEN bCancelado = 0
                THEN 'NO'
            END
        , c.tCreatedAt AS fechaCreacion
    FROM Cita AS c
    INNER JOIN HorarioUsuario AS hu
        ON c.horarioUsuarioId_fk = hu.id
    INNER JOIN Horario AS h
        ON hu.horarioId_fk = h.id
    INNER JOIN RolUsuario AS ru
        ON hu.rolUsuarioId_fk = ru.id
    INNER JOIN Rol AS r
        ON ru.rolId_fk = r.id
    INNER JOIN Sync_Usuario AS u
        ON ru.usuarioId_fk = u.id
    WHERE c.id = @ID
        AND c.bEliminado = 0
END
GO

