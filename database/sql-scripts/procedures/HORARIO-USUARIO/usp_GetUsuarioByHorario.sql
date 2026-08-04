/*======================================================================================================
NOMBRE: [dbo].[usp_GetUsuarioByHorario]
FECHA: 10-02-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: muestra el los usuarios relacionados a un horario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetUsuarioByHorario]
    @HORARIO_ID INT = NULL
AS
BEGIN

    SELECT
        H.id AS id
, U.cNombre AS nombre
, U.cApellido AS apellido
, U.cDni AS dni
, r.cTitulo AS rol
, UO.cTitulo AS unidad
, H.cTitulo AS titulo
, H.bRegular AS regular
, H.bExtendido AS extendido
, H.bRotativo AS rotativo
, H.bGeneral AS general
, H.horaDia
, T.cTemporada AS temporada
, T.idPeriodoLectivo AS periodoId
, T.idTemporada AS temporadaId
, T.cPeriodoLectivo as periodoLectivo
, RU.id AS idRolUsuario
, HU.tfechaInicio AS fechaInicio
, HU.tFechaFin AS fechaFin
, CASE 
            WHEN COUNT(DISTINCT HD.id) > 0
                THEN 1
            ELSE 0
            END AS diasAsignados
        , COUNT(DISTINCT HD.id) AS cantidadDias
    FROM HorarioUsuario HU
        INNER JOIN Horario H ON  HU.horarioId_fk = H.id
        LEFT JOIN HorarioDias HD ON HD.horarioId_fk = H.id
        INNER JOIN RolUsuario RU ON HU.rolUsuarioId_fk = RU.id
        INNER JOIN Sync_Usuario U ON RU.usuarioId_fk = U.id
        INNER JOIN Rol R ON RU.rolId_fk = R.id
        LEFT JOIN Unidad UD ON R.unidadId_fk = UD.id
        LEFT JOIN Sync_Unidad UO ON UD.unidadOrgId_fk = UO.id
        LEFT JOIN Sync_Temporada T ON H.idTemporada = T.idTemporada
    WHERE RU.id = @HORARIO_ID AND HU.bEliminado = 0
    GROUP BY H.id
    ,U.cNombre
    ,U.cApellido
    ,U.cDni
    ,R.cTitulo
    ,UO.cTitulo
    ,H.cTitulo
    ,H.bRegular
    ,H.bExtendido
    ,H.bRotativo
    ,H.bGeneral
    ,H.horaDia
    ,RU.id
    ,HU.tfechaInicio
    ,HU.tFechaFin
    ,T.idPeriodoLectivo
    ,T.idTemporada
    ,T.cPeriodoLectivo
    ,T.cTemporada
  

END
GO