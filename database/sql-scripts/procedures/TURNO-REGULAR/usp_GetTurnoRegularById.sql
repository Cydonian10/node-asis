/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoRegularById]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO:Permite listar todos los turnos regulares por Id.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetTurnoRegularById] @TURNOREGULARID INT
AS
BEGIN
    SELECT TR.id
        , TR.horarioDiasId_fk AS horarioDiasId
        , TR.orden AS orden
        , d.cTitulo AS dia
        , FORMAT(TR.horaInicio, 'HH:mm:ss') as horaInicio
        , CASE 
            WHEN TR.bTipo = 0
                THEN 'ENTRADA'
            ELSE 'SALIDA'
            END AS tipoTurno
        , CASE 
            WHEN HD.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS uso
    FROM TurnoRegular AS TR
    LEFT JOIN HorarioDias AS HD
        ON TR.horarioDiasId_fk = HD.id
            AND HD.bEliminado = 0
    INNER JOIN Dia as d
        ON HD.diaId_fk = d.id
            AND d.bEliminado = 0
    WHERE TR.id = @TURNOREGULARID
        AND TR.bEliminado = 0;
END
GO
