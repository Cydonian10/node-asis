/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoExtendidoById]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Listar todos los turnos extendido por id, no eliminados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetTurnoExtendidoById] @TURNOEXTENDIDOID INT
AS
BEGIN
    SELECT TE.id
        , TE.horarioDiasId_fk AS horarioDiasId
        , TE.horaInicio AS horaInicio
        , TE.horaFin AS horaFin
        , D.cTitulo AS dia
        , CASE 
            WHEN HD.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS uso
    FROM TurnoExtendido AS TE
    LEFT JOIN HorarioDias AS HD
        ON TE.horarioDiasId_fk = HD.id
    LEFT JOIN Dia D ON HD.diaId_fk = D.id
    WHERE TE.id = @TURNOEXTENDIDOID
        AND TE.bEliminado = 0
        AND HD.bEliminado = 0
END
GO
