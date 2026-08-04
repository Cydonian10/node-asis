SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlRolUsuarioAsistencia]
FECHA: 26-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener el estado de la asistencia con el control que se usó en este caso [ControlRolUsuario]

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER  PROCEDURE [dbo].[usp_GetControlRolUsuarioAsistencia]
    @ID INT = NULL,
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT
        cru.id,
        a.id as asistenciaId,
        ea.id as estadoAsistenciaId,
        ea.cNombre as estadoAsitencia,
        c.nTolerancia as tolerancia,
        c.nLimiteFalta as limiteFalta,
        c.nLimiteMarcacion as limiteMarcacion,
        cru.id rolControlId
    FROM ControlRolUsuarioAsistencia crua
        INNER JOIN ControlRolUsuario cru on cru.id = crua.controlRolUsuarioId_fk
        INNER JOIN [Controles] c on c.id = cru.controlId_fk
        INNER JOIN EstadoAsistencia ea on ea.id = crua.estadoAsistenciaId_fk
        INNER JOIN Asistencia a on a.id = crua.asistenciaId_fk
    WHERE 
        cru.bEliminado = 0 AND
        crua.bEliminado = 0 AND
        cru.bEliminado = 0 AND
        c.bEliminado = 0 AND
        ea.bEliminado = 0 AND
        a.bEliminado = 0 AND
       -- (@ID IS NULL OR crua.id = @ID) AND
        (@ASISTENCIA_ID IS NULL OR a.id = @ASISTENCIA_ID)
END
GO
