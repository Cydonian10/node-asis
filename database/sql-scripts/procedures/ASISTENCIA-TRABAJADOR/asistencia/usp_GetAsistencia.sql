SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetAsistencia]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar una asistencia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetAsistencia]
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT id, horaEntrada, horaSalida
    FROM Asistencia
    WHERE 
        id = @ASISTENCIA_ID AND
        bEliminado = 0
END
GO
