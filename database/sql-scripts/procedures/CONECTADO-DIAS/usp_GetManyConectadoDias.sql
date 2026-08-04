SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetManyConectadoDias]
FECHA: 17-09-2025
AUTOR: Jesamine Ramon Yora
OBJETIVO: Listar todos los registros de ConectadoDias.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER   PROCEDURE [dbo].[usp_GetManyConectadoDias]
    @TURNO_EXTENDIDO_ID INT 
AS
BEGIN
    SELECT CD.turnoExtendidoId_pk AS turnoExtendidoId
        , CD.diasId_pk AS diasId
        , D.cTitulo AS Dia
        , TE.horaInicio
        , TE.horaFin
    FROM ConectadoDias AS CD
    INNER JOIN TurnoExtendido AS TE
        ON CD.turnoExtendidoId_pk = TE.id
    INNER JOIN Dia AS D
        ON CD.diasId_pk = D.id
    WHERE TE.bEliminado = 0
        AND D.bEliminado = 0
        AND TE.id = @TURNO_EXTENDIDO_ID
END;
GO
