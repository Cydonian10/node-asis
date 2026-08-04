SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetAsistenciaRegular]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listas las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetAsistenciaRegular]
AS
BEGIN
    SELECT AR.Id AS id
        , AR.turnoRegularId_fk AS id_turno
        , AR.asistenciaId_fk AS id_asistencia
        , AR.marcacionId_fk AS id_marcacion
        , AR.detalleBiometricoId_fk AS id_detalleBiometrico
        , U.cUsuario AS usuario
        , U.cNombre AS nombre
        , RU.usuarioId_fk AS id_usuario
        , CONVERT(CHAR(10),A.tFecha,103) AS fecha
        , DB.cNombre AS biometrico
        , DB.ubicacion AS ubicacion
        , CONVERT(CHAR(8),M.punch_time,108) AS hora
    FROM AsistenciaRegular AR
        INNER JOIN Asistencia A ON AR.asistenciaId_fk = A.id
        INNER JOIN Marcacion M ON AR.marcacionId_fk = M.id
        INNER JOIN Sync_Usuario U ON M.emp_id = U.id
        INNER JOIN RolUsuario RU ON U.id = RU.usuarioId_fk
        INNER JOIN DetalleBiometrico DB ON AR.detalleBiometricoId_fk = DB.id
        INNER JOIN TurnoRegular TR ON AR.turnoRegularId_fk = TR.id
    WHERE AR.bEliminado = 0
END
GO
