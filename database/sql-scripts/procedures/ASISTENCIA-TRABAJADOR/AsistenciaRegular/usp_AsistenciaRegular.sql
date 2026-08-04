SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_AsistenciaRegular]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar marcaciones reales por asistencia id de asistencia regular

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_AsistenciaRegular]
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT 
        m.punch_time as marcacionReal
    FROM AsistenciaRegular ar
        INNER JOIN Asistencia a on a.id = ar.asistenciaId_fk
        INNER JOIN Marcacion m on m.id = ar.marcacionId_fk
    WHERE 
    m.bEliminado = 0 AND
    a.bEliminado = 0 AND
    ar.bEliminado = 0 AND
    ar.asistenciaId_fk = @ASISTENCIA_ID
END
GO
