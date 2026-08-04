/*======================================================================================================
NOMBRE: [dbo].[usp_GetPermisoTurnoRegularById]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Lista el permisoTurnoRegular por ID persmiso y turno.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetPermisoTurnoRegularById] @PERMISOID INT
    , @TURNOID INT
AS
BEGIN
SELECT
        U.cNombre, U.cApellido,
        M.nombre, TR.horaInicio,
        P.tfecha, P.tHoraSalida,
        P.id AS permisoId,
        TR.id AS turnoId

    FROM PermisoTurnoRegular AS PR
        LEFT JOIN TurnoRegular AS TR
        ON PR.turnoRegularId_pk = TR.id
            AND TR.bEliminado = 0
        INNER JOIN Permiso AS P
        ON PR.permisoId_pk = P.id
            AND P.bEliminado = 0
        INNER JOIN Motivo AS M
        ON P.motivoId_fk = M.id
            AND M.bEliminado = 0
        INNER JOIN RolUsuario as RU
        ON P.rolUsuarioId_fk = RU.id
            AND RU.bEliminado = 0
        INNER JOIN Sync_Usuario as U
        ON RU.usuarioId_fk = U.id
    WHERE PR.permisoId_pk = @PERMISOID
END;
GO