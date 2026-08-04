SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoRegular]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite listar todos los turnos regulares no eliminados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetTurnoRegular]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TR.id
        , TR.horarioDiasId_fk
        , TR.orden
        , TR.horaInicio
        , CASE 
            WHEN TR.bTipo = 0
                THEN 'ENTRADA'
            WHEN TR.bTipo = 1
                THEN 'SALIDA'
            END AS TipoTurno
        , CASE 
            WHEN HD.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS USO
    FROM TurnoRegular AS TR
    LEFT JOIN HorarioDias AS HD
        ON TR.horarioDiasId_fk = HD.id
            AND HD.bEliminado = 0
    -- LEFT JOIN Vigencia AS V
    --     ON V.horarioDiasId_pk = HD.id
    WHERE TR.bEliminado = 0
    -- AND V.bEliminado = 0
    ORDER BY TR.id
END
GO
