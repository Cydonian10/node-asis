SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetPermisoById]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite obtener la lista de permisos por ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetPermisoById] @PERMISOID INT
AS
BEGIN
    SELECT rolUsuarioId_fk
        , motivoId_fk
        , P.tfecha
        , P.tHoraSalida
        , P.tHoraRetornoEstimado
        , P.tHoraRetornoReal
        , M.nombre AS nombreMotivo
        , RU.usuarioId_fk
    FROM Permiso AS P
    INNER JOIN Motivo AS M
        ON P.motivoId_fk = M.id
    INNER JOIN RolUsuario AS RU
        ON RU.id = P.rolUsuarioId_fk
    WHERE P.id = @PERMISOID
        AND P.bEliminado = 0
        AND M.bEliminado = 0
        AND RU.bEliminado = 0
END
GO
