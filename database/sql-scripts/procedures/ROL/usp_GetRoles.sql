/*======================================================================================================
NOMBRE: [dbo].[usp_GetRoles]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Listar el catalogo global de roles (Rol). Son filas fijas (seed): Supervisor, Asistente,
          Usuario. Excluye Eliminado = 1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetRoles]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        RolId AS rolId,
        Nombre AS nombre,
        Descripcion AS descripcion
    FROM Rol
    WHERE Eliminado = 0;
END
GO
