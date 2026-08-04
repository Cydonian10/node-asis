/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlVacacionesByUsuarioId]
FECHA: 23-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar el control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetControlVacacionesByUsuarioId] 
    @IDROLUSUARIO INT
AS
BEGIN
    SELECT CV.id
        , CV.rolUsuarioId_fk AS id_rolUsuario
        , CV.nDiasDisponibles AS diasDisponibles
        , CV.nDiasTomados AS diasTomados
        , CV.bAprobado AS aprobado
        , CV.nAprobadoBy AS idaprobado
    FROM ControlVacaciones CV
    WHERE rolUsuarioId_fk = @IDROLUSUARIO
        AND bEliminado = 0
END
GO
