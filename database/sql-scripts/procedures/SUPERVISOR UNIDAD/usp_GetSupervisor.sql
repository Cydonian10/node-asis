--===================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetSupervisor]
-- Fecha: 06-10-2025
-- Descripcion: Procedimiento para mostrar todos los registros de la tabla Supervisor
-- Parámetros a mostrar: 
-- @USUARIO_ID: id de un registro de la tabla Sync_Usuario (int)
-- @UNIDAD_ID: id de un registro de la tabla Unidad (int)
-- @USUARIO: el nombre del usuario
-- @TITULO : El nombre de la unidad 
--===================================================================================
CREATE OR ALTER PROCEDURE [dbo].[usp_GetSupervisor]

AS
BEGIN 
    SET NOCOUNT ON;

    SELECT su.usuarioId_pk, u.cUsuario, u.cNombre as nombre, u.cApellido as apellido ,su.unidadId_pk, ud.cTitulo AS titulo
    FROM Supervisor AS su 
    INNER JOIN Sync_Usuario AS u ON  su.usuarioId_pk = u.id
    INNER JOIN Unidad AS un ON su.unidadId_pk = un.id
    INNER JOIN Sync_Unidad AS  ud ON un.unidadOrgId_fk = ud.id
    WHERE su.bEliminado = 0
END
GO