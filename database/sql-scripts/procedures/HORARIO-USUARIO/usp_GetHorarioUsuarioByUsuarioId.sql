/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioUsuarioByUsuarioId]
FECHA: 20-01-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: muestra el Horario completo a partir del id de usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorarioUsuarioByUsuarioId]
    @ROL_USUARIO_ID INT = NULL,
    @HORARIO_ID INT = NULL
AS
BEGIN
    SELECT
        HU.id,
        HU.horarioId_fk AS idHorario,
        H.cTitulo AS titulo,
        H.horaDia AS horas,
        -- HU.rolUsuarioId_fk AS idRolUsuario,
        SU.cApellido AS apellidos,
        SU.cNombre AS nombre,
        HU.tfechaInicio AS fechaInicio,
        HU.tFechaFin AS fechaFin,
        RU.usuarioId_fk AS idUsuario,
        SU.cUsuario AS usuario,
        D.cTitulo AS dia,
        HD.id AS horarioDiaId,
        TR.horaInicio,
        tipo = CASE 
 WHEN  TR.bTipo = 1  THEN 'Salida'
 WHEN TR.bTipo = 0  THEN 'Entrada'
 END
    FROM HorarioUsuario HU
        INNER JOIN HORARIO H
        ON HU.horarioId_fk = H.id
        INNER JOIN HorarioDias HD
        ON HD.horarioId_fk = H.id
        INNER JOIN Dia D
        ON HD.diaId_fk = D.id
        LEFT JOIN TurnoRegular TR
        ON HD.id = TR.horarioDiasId_fk
        LEFT JOIN TurnoExtendido TE 
        ON HD.id = TE.horarioDiasId_fk
        INNER JOIN RolUsuario RU
        ON HU.rolUsuarioId_fk = RU.id
        INNER JOIN Sync_Usuario SU
        ON RU.usuarioId_fk = SU.id
    WHERE  HU.bEliminado = 0 AND H.bEliminado = 0 AND TR.bEliminado = 0
        AND RU.id = @ROL_USUARIO_ID AND H.id = @HORARIO_ID
    GROUP BY H.id,
      HU.id,
    HU.horarioId_fk,
    H.cTitulo ,
    H.horaDia,
    -- HU.rolUsuarioId_fk AS idRolUsuario,
    SU.cApellido ,
    SU.cNombre,
    HU.tfechaInicio,
    HU.tFechaFin,
    RU.usuarioId_fk,
    SU.cUsuario,
    D.cTitulo,
    HD.id,
    TR.horaInicio,
    TR.bTipo,
     d.orden
END
GO
