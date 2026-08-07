/*======================================================================================================
NOMBRE: [dbo].[usp_GetUsuarioByDni]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Resolver el usuario desde el codigo de la marcacion (EmpCode = DNI de SyncUsuarios).
          Devuelve UsuarioId, AreaId y UnidadId (Area.UnidadId). Vacio si no hay match.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUsuarioByDni]
    @EmpCode VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.UsuarioId AS usuarioId,
        U.AreaId AS areaId,
        A.UnidadId AS unidadId
    FROM SyncUsuarios S
    INNER JOIN Usuario U ON U.SyncUsuarioId = S.SyncUsuarioId AND U.Eliminado = 0 AND U.Active = 1
    INNER JOIN Area A ON A.AreaId = U.AreaId AND A.Eliminado = 0
    WHERE S.Dni = @EmpCode;
END
GO
