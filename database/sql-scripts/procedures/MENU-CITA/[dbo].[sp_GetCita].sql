IF EXISTS (
  SELECT * 
   FROM INFORMATION_SCHEMA.ROUTINES
  WHERE SPECIFIC_SCHEMA = N'dbo'
   AND SPECIFIC_NAME = N'sp_GetCita'
   AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE [dbo].[sp_GetCita]
GO

/*======================================================================================================
NOMBRE: [dbo].[sp_GetCita]
FECHA: 26-09-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: Procedimiento para mostrar todas las citas que fueron creadas

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
01   02-01-2026  FLUNA      Añadir alias
======================================================================================================*/
CREATE PROCEDURE [dbo].[sp_GetCita]
AS
BEGIN
    SELECT c.id AS id
        , hu.id AS horarioUsuarioId
        , h.cTitulo AS horario
        , u.cUsuario AS usuario
        , c.nombre AS nombre
        , r.cTitulo AS rol
        , c.cDescripcion AS descripcion
        , CONVERT(VARCHAR(10), c.fecha, 120) AS fecha
        , CONVERT(CHAR(5), c.hora, 108) AS hora
        , cancelado = CASE 
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
    WHERE c.bEliminado = 0
END
GO
-- GRANT EXECUTE ON [dbo].[sp_GetCita] TO u_r_sgicomplejo
-- GO