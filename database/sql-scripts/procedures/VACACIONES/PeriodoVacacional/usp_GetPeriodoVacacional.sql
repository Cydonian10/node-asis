/*======================================================================================================
NOMBRE: [dbo].[usp_GetPeriodoVacacional]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar periodos vacacionales

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_GetPeriodoVacacional] 
    @IDCONTROLVACACIONAL INT
AS
BEGIN
    SELECT PV.id
        , PV.fechaInicio AS fechaInicio
        , PV.fechaFin AS fechaFin
        , PV.nDiasConsumidos AS diasConsumidos
    FROM PeriodoVacacional PV
    WHERE bEliminado = 0
        AND PV.controlVacacionalId_fk = @IDCONTROLVACACIONAL
END
GO
