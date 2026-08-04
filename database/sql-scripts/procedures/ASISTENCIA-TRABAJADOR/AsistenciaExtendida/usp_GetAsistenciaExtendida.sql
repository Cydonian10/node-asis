SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetAsistenciaExtendida]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listas las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetAsistenciaExtendida]
AS
BEGIN
    SELECT AE.Id AS id
        , AE.turnoExtendidoId_fk AS id_turno
        , AE.asistenciaId_fk AS id_asistencia
        , AE.marcacionId_fk AS id_marcacion
        , AE.detalleBiometricoId_fk AS id_biometrico
        , CONVERT(CHAR(10),A.tFecha,103) AS fecha
        , DB.cNombre AS biometrico
        , DB.ubicacion AS ubicacion
        , CONVERT(CHAR(8),M.punch_time,108) AS hora
    FROM AsistenciaExtendida AE
    INNER JOIN Asistencia A ON AE.asistenciaId_fk = A.id
    INNER JOIN DetalleBiometrico DB ON AE.detalleBiometricoId_fk = DB.id
    INNER JOIN Marcacion M ON AE.marcacionId_fk = M.id
    WHERE AE.bEliminado = 0
END
GO
