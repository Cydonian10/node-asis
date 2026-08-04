SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetRolControlAsistenciaEstado]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar controles de rolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetRolControlAsistenciaEstado]
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT
        a.id asistenciaId,
        ea.id estadoAsistenciaId,
        ea.cNombre estadoAsitencia,
        c.nTolerancia tolerancia,
        c.nLimiteFalta limiteFalta,
        c.nLimiteMarcacion limiteMarcacion,
        rc.id rolControlId
    FROM RolControlAsistencia rca
        INNER JOIN RolControl rc on rc.id = rca.rolControlId_fk
        INNER JOIN Controles c on c.id = rc.controlId_fk
        INNER JOIN EstadoAsistencia ea on ea.id = rca.estadoAsistenciaId_fk
        INNER JOIN Asistencia a on a.id = rca.asistenciaId_fk
    WHERE 
        rc.bEliminado = 0 AND
        rca.bEliminado = 0 AND
        rc.bEliminado = 0 AND
        c.bEliminado = 0 AND
        ea.bEliminado = 0 AND
        A.bEliminado = 0 AND
        a.id = @ASISTENCIA_ID
END
GO
