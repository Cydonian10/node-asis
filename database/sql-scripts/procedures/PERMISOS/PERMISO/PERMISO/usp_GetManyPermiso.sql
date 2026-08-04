SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetManyPermiso]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite obtener la lista de permisos.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetManyPermiso]
AS
BEGIN
    SELECT rolUsuarioId_fk
        , motivoId_fk 
        , M.nombre AS tituloMotivo
        , P.tfecha
        , P.tHoraSalida
        , P.tHoraRetornoEstimado
        , P.tHoraRetornoReal
        , RU.usuarioId_fk AS rolUsuario
    FROM Permiso AS P
    INNER JOIN Motivo AS M
        ON P.motivoId_fk = M.id
    INNER JOIN RolUsuario AS RU
        ON RU.id = P.rolUsuarioId_fk
    WHERE P.bEliminado = 0
        AND M.bEliminado = 0
        AND RU.bEliminado = 0
END
GO
