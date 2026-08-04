SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlUnidadAsistenciaEstado]
FECHA: 26-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Visualizar el estado de asistencia 

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetControlUnidadAsistenciaEstado]
    @ID INT = NULL,
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT
        a.id as asistenciaId,
        ea.id as estadoAsistenciaId,
        ea.cNombre as estadoAsitencia,
        c.nTolerancia as tolerancia,
        c.nLimiteFalta as limiteFalta,
        c.nLimiteMarcacion as limiteMarcacion,
        cu.id CONTROL_UNIDAD_ID
    FROM ControlUnidadAsistencia cua
        INNER JOIN ControlUnidad cu on cu.id = cua.controlUnidadId_fk
        INNER JOIN Controles c on c.id = cu.controlId_fk
        INNER JOIN EstadoAsistencia ea on ea.id = cua.estadoAsistenciaId_fk
        INNER JOIN Asistencia a on a.id = cua.asistenciaId_fk
    WHERE 
        cu.bEliminado = 0 AND
        cua.bEliminado = 0 AND
        cu.bEliminado = 0 AND
        c.bEliminado = 0 AND
        ea.bEliminado = 0 AND
        a.bEliminado = 0 AND
        (@ID IS NULL OR cua.id = @ID) AND
        (@ASISTENCIA_ID IS NULL OR a.id = @ASISTENCIA_ID)
END
GO
