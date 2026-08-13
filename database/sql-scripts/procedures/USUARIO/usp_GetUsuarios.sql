/*======================================================================================================
NOMBRE: [dbo].[usp_GetUsuarios]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Listar usuarios migrados (JOIN SyncUsuarios + Usuario + Area + Unidad + SyncUnidad) con
          filtros opcionales. La unidad se deriva de Area.UnidadId (SPEC 04).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  1  13-08-2026  Gabriel    Agrega filtro @unidadId y campo unidadNombre (SyncUnidad.Nombre).
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUsuarios]
    -- Parametros de entrada
    @activo BIT = NULL,
    @tipo VARCHAR(10) = NULL,
    @busqueda VARCHAR(255) = NULL,
    @areaId INT = NULL,
    @unidadId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.UsuarioId AS usuarioId,
        SU.SyncUsuarioId AS syncUsuarioId,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos,
        SU.Dni AS dni,
        SU.Tipo AS tipo,
        U.Active AS activo,
        U.AreaId AS areaId,
        A.Nombre AS areaNombre,
        A.UnidadId AS unidadId,
        SY.Nombre AS unidadNombre,
        U.EsSupervisor AS esSupervisor
    FROM Usuario U
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    INNER JOIN Area A ON A.AreaId = U.AreaId
    INNER JOIN Unidad UN ON UN.UnidadId = A.UnidadId
    INNER JOIN SyncUnidad SY ON SY.SyncUnidadId = UN.SyncUnidadId
    WHERE U.Eliminado = 0
        AND A.Eliminado = 0
        AND (@activo IS NULL OR U.Active = @activo)
        AND (@tipo IS NULL OR SU.Tipo = @tipo)
        AND (@areaId IS NULL OR U.AreaId = @areaId)
        AND (@unidadId IS NULL OR A.UnidadId = @unidadId)
        AND (
            @busqueda IS NULL
            OR SU.Usuario LIKE '%' + @busqueda + '%'
            OR SU.Nombres LIKE '%' + @busqueda + '%'
            OR SU.Apellidos LIKE '%' + @busqueda + '%'
            OR SU.Dni LIKE '%' + @busqueda + '%'
        );
END
GO
