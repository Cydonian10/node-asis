/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioUsuario]
FECHA: 03-10-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar horario usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorarioUsuario]
AS
BEGIN
    SELECT HU.id
        , HU.horarioId_fk AS idHorario
        , HU.rolUsuarioId_fk AS idRolUsuario
        , SU.cApellido AS apellidos
        , SU.cNombre AS nombre
        , CAST(HU.tfechaInicio as VARCHAR(10)) AS fechaInicio
        , CAST(HU.tFechaFin as VARCHAR(10)) AS fechaFin
        , H.cTitulo AS tituloHorario
        , RU.usuarioId_fk AS idUsuario
        , SU.cUsuario AS usuario
    FROM HorarioUsuario HU
        INNER JOIN HORARIO H
        ON HU.horarioId_fk = H.id
        INNER JOIN RolUsuario RU
        ON HU.rolUsuarioId_fk = RU.id
        INNER JOIN Sync_Usuario SU
        ON RU.usuarioId_fk = SU.id
    WHERE HU.bEliminado = 0
    ORDER BY HU.id DESC
END
GO
