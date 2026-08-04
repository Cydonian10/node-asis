SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_AsistenciaModificada]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar marcaciones reales por asistencia id de asistencia modificada

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_AsistenciaModificada]
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT 
        m.punch_time as marcacionReal
    FROM AsistenciaModificada am
        INNER JOIN Asistencia a on a.id = am.asistenciaId_fk
        INNER JOIN Marcacion m on m.id = am.marcacionId_fk
    WHERE 
    m.bEliminado = 0 AND
    a.bEliminado = 0 AND
    am.bEliminado = 0 AND
    am.asistenciaId_fk = @ASISTENCIA_ID
END
GO
