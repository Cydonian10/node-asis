/*======================================================================================================
NOMBRE: [dbo].[usp_GetConectadoDiasByIds]
FECHA: 17-09-2025
AUTOR: Jesamine Ramon Yora
OBJETIVO: Obtener un registro de ConectadoDias por IDs.
          
MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetConectadoDiasByIds] @TURNOEXTENDIDOID INT
    , @DIASID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CD.turnoExtendidoId_pk
        , CD.diasId_pk
        , D.cTitulo AS Dia
        , TE.horaInicio
        , TE.horaFin
        -- , HD.id AS HorarioDiasId
        -- , HD.horarioId_fk AS HorarioId
    FROM ConectadoDias AS CD
    INNER JOIN Dia AS D
        ON CD.diasId_pk = D.id
    INNER JOIN TurnoExtendido AS TE
        ON CD.turnoExtendidoId_pk = TE.id
    -- INNER JOIN HorarioDias AS HD
    --     ON TE.horarioDiasId_fk = HD.id
    WHERE CD.turnoExtendidoId_pk = @TURNOEXTENDIDOID
        AND CD.diasId_pk = @DIASID
        AND D.bEliminado = 0
        AND TE.bEliminado = 0
        -- AND HD.bEliminado = 0
    GROUP BY CD.turnoExtendidoId_pk
        , CD.diasId_pk
        , D.cTitulo
        , TE.horaInicio
        , TE.horaFin
        -- , HD.id
        -- , HD.horarioId_fk;
END
GO
