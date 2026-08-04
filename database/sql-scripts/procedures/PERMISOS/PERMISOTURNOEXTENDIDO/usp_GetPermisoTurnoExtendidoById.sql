/*======================================================================================================
NOMBRE: [dbo].[usp_GetPermisoTurnoExtendidoById]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Lista el permisoTurnoExtendido por ID persmiso y turno.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE  OR ALTER PROCEDURE [dbo].[usp_GetPermisoTurnoExtendidoById] @PERMISOID INT
    , @TURNOID INT
AS
BEGIN
   SELECT
        U.cNombre, U.cApellido,
        M.nombre, TE.horaInicio,
        P.tfecha, P.tHoraSalida
        ,P.id AS permisoId
        ,TE.id AS turnoId

    FROM PermisoTurnoExtendido AS PE
        LEFT JOIN TurnoExtendido AS TE
        ON PE.turnoExtendidoId_pk = TE.id
            AND TE.bEliminado = 0
        INNER JOIN Permiso AS P
        ON PE.permisoId_pk = P.id
            AND P.bEliminado = 0
        INNER JOIN Motivo AS M
        ON P.motivoId_fk = M.id
            AND M.bEliminado = 0
        INNER JOIN RolUsuario as RU
        ON P.rolUsuarioId_fk = RU.id
            AND RU.bEliminado = 0
        INNER JOIN Sync_Usuario as U
        ON RU.usuarioId_fk = U.id
    WHERE PE.permisoId_pk = @PERMISOID
END;
GO
