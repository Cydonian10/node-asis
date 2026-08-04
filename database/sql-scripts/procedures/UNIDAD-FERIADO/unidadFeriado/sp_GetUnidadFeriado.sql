--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetUnidadFeriado]
-- Fecha:  02-10-2025
-- Descripcion: Procedimiento para mostrar todos los resgistros de Unidad Feriado 
--=======================================================================================

CREATE OR ALTER PROCEDURE [dbo].[sp_GetUnidadFeriado]
  @UNIDADID INT

AS
BEGIN
    SET NOCOUNT ON; 
    
    SELECT su.cTitulo AS Unidad,df.cDenominacion AS Feriado, f.fecha
    FROM UnidadFeriado AS uf
    INNER JOIN Unidad AS u ON uf.unidadId_pk = u.id
    INNER JOIN Sync_Unidad AS su ON u.unidadOrgId_fk = su.id
    INNER JOIN FechaFeriado AS f ON uf.fechaFeriadoId_pk = f.id
    INNER JOIN DenominacionFeriado AS df ON f.denominacionFeriadoId_fk = df.id
    WHERE u.id = @UNIDADID

END