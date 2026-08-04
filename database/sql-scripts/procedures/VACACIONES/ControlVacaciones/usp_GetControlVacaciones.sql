/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlVacaciones]
FECHA: 23-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar el control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetControlVacaciones]
AS
BEGIN
    SELECT CV.id
        , CV.rolUsuarioId_fk AS id_rolUsuario
        , CV.nDiasDisponibles AS diasDisponibles
        , CV.nDiasTomados AS diasTomados
        , CV.bAprobado AS aprobado
        , CV.nAprobadoBy AS idaprobado
    FROM ControlVacaciones CV
	WHERE bEliminado = 0
END
GO