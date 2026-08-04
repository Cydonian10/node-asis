--===================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetSupervisorId]
-- Fecha: 30-10-2025
-- Descripcion: Procedimiento para mostrar todos los registros de los supervisores por unidad
-- Parámetros: 
-- @UNIDAD_ID: id de un registro de la tabla Unidad (int)
--===================================================================================

CREATE OR ALTER PROCEDURE [dbo].[usp_GetSupervisorId]
    @UNIDAD_ID  INT 
AS 
BEGIN 
    SET NOCOUNT ON;

    SELECT su.usuarioId_pk as usuarioId, u.cNombre as nombre, u.cApellido as apellido, u.cUsuario as Usuario, su.unidadId_pk as unidadId, ud.cTitulo as titulo
    FROM Supervisor AS su 
    INNER JOIN Sync_Usuario AS u ON  su.usuarioId_pk = u.id
    INNER JOIN Unidad AS un ON su.unidadId_pk = un.id
    INNER JOIN Sync_Unidad AS  ud ON un.unidadOrgId_fk = ud.id
    WHERE su.unidadId_pk = @UNIDAD_ID AND su.bEliminado = 0
END
GO