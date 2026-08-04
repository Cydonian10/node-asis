SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoExtendido]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Listar todos los turnos extendido, no eliminados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER PROCEDURE [dbo].[usp_GetTurnoExtendido]
AS
BEGIN
    SELECT TE.id
        , TE.horarioDiasId_fk
        , D.cTitulo AS Dia
        , H.cTitulo AS Horario
        , horaInicio  as horaInicio
        , TE.horaFin as horaFin
        , CASE 
            WHEN HD.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS USO
    FROM TurnoExtendido AS TE
        LEFT JOIN HorarioDias AS HD
        ON TE.horarioDiasId_fk = HD.id
        LEFT JOIN Dia AS D
        ON HD.diaId_fk = D.id
        LEFT JOIN Horario AS H
        ON HD.horarioId_fk = H.id
    WHERE TE.bEliminado = 0
        AND HD.bEliminado = 0
END
GO
