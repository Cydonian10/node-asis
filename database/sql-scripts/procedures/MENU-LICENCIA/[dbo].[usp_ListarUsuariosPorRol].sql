IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_ListarUsuariosPorRol'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_ListarUsuariosPorRol];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_ListarUsuariosPorRol]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar roles de un usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_ListarUsuariosPorRol] @UNIDAD_ID INT
    , @ROL_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ru.id rolUsuarioId
        , su.id usuarioId
        , su.cNombre nombre
        , su.cApellido apellidos
        , su.cTipo tipo
        , su.cUsuario usuario
        , r.cTitulo
    FROM Sync_Usuario su
    INNER JOIN RolUsuario ru
        ON ru.usuarioId_fk = su.id
    INNER JOIN Rol r
        ON r.id = ru.rolId_fk
    WHERE ru.bEliminado = 0
        AND r.bEliminado = 0
        AND (
            @UNIDAD_ID IS NULL
            OR r.unidadId_fk = @UNIDAD_ID
            )
        AND (
            @ROL_ID IS NULL
            OR ru.rolId_fk = @ROL_ID
            );
END
GO


