/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioUsuarios]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Listar los usuarios asignados a un horario (HorarioAsignacion JOIN Usuario + SyncUsuarios).
          Excluye asignaciones y usuarios con Eliminado = 1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorarioUsuarios]
    -- Parametros de entrada
    @HorarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        HA.HorarioAsignacionId AS horarioAsignacionId,
        HA.UsuarioId AS usuarioId,
        SU.SyncUsuarioId AS syncUsuarioId,
        SU.Usuario AS usuario,
        SU.Nombres AS nombres,
        SU.Apellidos AS apellidos,
        HA.FechaInicio AS fechaInicio,
        HA.FechaFin AS fechaFin
    FROM HorarioAsignacion HA
    INNER JOIN Usuario U ON U.UsuarioId = HA.UsuarioId
    INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = U.SyncUsuarioId
    WHERE HA.HorarioId = @HorarioId
        AND HA.Eliminado = 0
        AND U.Eliminado = 0;
END
GO
