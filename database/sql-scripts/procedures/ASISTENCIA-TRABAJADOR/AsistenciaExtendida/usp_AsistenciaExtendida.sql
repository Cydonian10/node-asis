SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_AsistenciaExtendida]
FECHA: 26-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar marcaciones reales por asistencia id de asistencia extendida

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_AsistenciaExtendida]
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT 
        m.punch_time as marcacionReal
    FROM AsistenciaExtendida ae
        INNER JOIN Asistencia a on a.id = ae.asistenciaId_fk
        INNER JOIN Marcacion m on m.id = ae.marcacionId_fk
    WHERE 
    m.bEliminado = 0 AND
    a.bEliminado = 0 AND
    ae.bEliminado = 0 AND
    ae.asistenciaId_fk = @ASISTENCIA_ID
END
GO
