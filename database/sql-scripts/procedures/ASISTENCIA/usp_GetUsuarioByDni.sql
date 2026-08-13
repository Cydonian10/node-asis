/*======================================================================================================
NOMBRE: [dbo].[usp_GetUsuarioByDni]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Resolver el usuario desde el codigo de la marcacion (EmpCode = DNI de SyncUsuarios).
          Devuelve solo UsuarioId (modelo multi-area: el area se deriva del horario del turno).
          Vacio si no hay match.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  1  13-08-2026  Gabriel    Multi-area: quita AreaId/UnidadId (se derivan del turno en usp_GetTurnoVigente).
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUsuarioByDni]
    @EmpCode VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.UsuarioId AS usuarioId
    FROM SyncUsuarios S
    INNER JOIN Usuario U ON U.SyncUsuarioId = S.SyncUsuarioId AND U.Eliminado = 0 AND U.Active = 1
    WHERE S.Dni = @EmpCode;
END
GO
