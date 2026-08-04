IF EXISTS (
  SELECT *
FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
  AND SPECIFIC_NAME = N'usp_GetHorarioUsuarioById'
  AND ROUTINE_TYPE = N'PROCEDURE'
)
DROP PROCEDURE [dbo].[usp_GetHorarioUsuarioById]
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioUsuarioById]
FECHA: 03-10-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar horario usuario por id

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 01  05/01/2026  fluna      añadir nombre de usuario
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorarioUsuarioById]
  @IDHORARIOUSUARIO INT
AS
BEGIN
  SELECT HU.id
        , HU.horarioId_fk AS idHorario
        , HU.rolUsuarioId_fk AS idRolUsuario
        , HU.tfechaInicio AS fechaInicio
        , HU.tFechaFin AS fechaFin
        , H.cTitulo AS tituloHorario
        , RU.usuarioId_fk AS idUsuario
        , SU.cUsuario AS usuario
        , SU.cNombre+' '+SU.cApellido AS nombre
  FROM HorarioUsuario HU
    INNER JOIN HORARIO H ON HU.horarioId_fk = H.id
    INNER JOIN RolUsuario RU ON HU.rolUsuarioId_fk = RU.id
    INNER JOIN Sync_Usuario SU ON RU.usuarioId_fk = SU.id
  WHERE HU.bEliminado = 0
    AND HU.id = @IDHORARIOUSUARIO
END
GO

-- GRANT EXECUTE ON [dbo].[usp_GetHorarioUsuarioById] TO u_r_sgicomplejo
-- GO