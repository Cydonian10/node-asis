SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_ListAsistenciasUsuarioRol]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Seleccionar Horarios de Usuario Rol

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListAsistenciasUsuarioRol]
    @ROL_USUARIO_ID INT
AS
BEGIN
    SELECT 
        a.id,
        a.tFecha as fecha,
        a.horaEntrada as horaEntrada,
        a.horaSalida as horaSalida,
        a.rolUsuarioid_fk as rolUsuarioId
        FROM Asistencia a
        WHERE rolUsuarioid_fk = @ROL_USUARIO_ID
        AND CAST(tFecha AS DATE) =  CAST(DATEADD(DAY,0, GETDATE()) AS DATE)
        AND bEliminado = 0
END


-- EXEC dbo.usp_ListAsistenciasUsuarioRol
--     @ROL_USUARIO_ID = 1


GO
