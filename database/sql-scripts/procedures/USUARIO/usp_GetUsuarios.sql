/*======================================================================================================
NOMBRE: [dbo].[usp_GetUsuarios]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Listar usuarios migrados (JOIN SyncUsuarios + Usuario + Area) con filtros opcionales.
          La unidad se deriva de Area.UnidadId (SPEC 04).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUsuarios]
    -- Parametros de entrada
    @activo BIT = NULL,
    @tipo VARCHAR(10) = NULL,
    @busqueda VARCHAR(255) = NULL,
    @areaId INT = NULL
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
        U.EsSupervisor AS esSupervisor
    FROM Usuario U
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    INNER JOIN Area A ON A.AreaId = U.AreaId
    WHERE U.Eliminado = 0
        AND A.Eliminado = 0
        AND (@activo IS NULL OR U.Active = @activo)
        AND (@tipo IS NULL OR SU.Tipo = @tipo)
        AND (@areaId IS NULL OR U.AreaId = @areaId)
        AND (
            @busqueda IS NULL
            OR SU.Usuario LIKE '%' + @busqueda + '%'
            OR SU.Nombres LIKE '%' + @busqueda + '%'
            OR SU.Apellidos LIKE '%' + @busqueda + '%'
            OR SU.Dni LIKE '%' + @busqueda + '%'
        );
END
GO
