SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarios]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Listar todos los horarios registrados que tiene asignados un HorarioDias

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
<<<<<<< Updated upstream
CREATE OR ALTER PROCEDURE [dbo].[usp_GetHorarios]
=======
ALTER   PROCEDURE [dbo].[usp_GetHorarios]
>>>>>>> Stashed changes
    @ROL_USUARIO_ID INT = NULL
AS
BEGIN
    SELECT H.id
        , H.cTitulo AS titulo
        , H.horaDia
        , H.bGeneral AS general
        , H.bExtendido AS extendido
        , H.bRotativo AS rotativo
        , H.bRegular AS regular
        , T.cTemporada AS temporada
        , T.idPeriodoLectivo AS periodoId
        , T.idTemporada AS temporadaId
        , T.cPeriodoLectivo as periodoLectivo
        , CASE  
             WHEN H.idTemporada = T.idTemporada THEN 1
             ELSE 0
            END  as horarioAcademico
        , CASE 
            WHEN COUNT(DISTINCT HU.id) > 0
            OR COUNT(DISTINCT HD.id) > 0
                THEN 1
            ELSE 0
            END AS enUso
        , CASE 
            WHEN COUNT(DISTINCT HD.id) > 0
                THEN 1
            ELSE 0
            END AS diasAsignados
        , COUNT(DISTINCT HD.id) AS cantidadDias

    -- , COUNT(DISTINCT HU.id) AS cantidadUsuarios
    FROM Horario H
        LEFT JOIN HorarioDias HD
        ON HD.horarioId_fk = H.id
            AND HD.bEliminado = 0
        LEFT JOIN HorarioUsuario HU
        ON HU.horarioId_fk = H.id
            AND HU.bEliminado = 0
<<<<<<< Updated upstream
    WHERE H.bEliminado = 0
=======
        LEFT JOIN Sync_Temporada T ON H.idTemporada = T.idTemporada
    WHERE H.bEliminado = 0 
>>>>>>> Stashed changes
        AND (@ROL_USUARIO_ID IS NULL OR HU.rolUsuarioId_fk = @ROL_USUARIO_ID)
    GROUP BY H.id
        , H.cTitulo
        , H.horaDia
        , H.bGeneral
        , H.bExtendido
        , H.bRotativo
        , H.bRegular
        , T.cTemporada
        , T.cPeriodoLectivo
        , T.idTemporada
        , H.idTemporada
        , T.idPeriodoLectivo
    ORDER BY h.id DESC
END
GO

