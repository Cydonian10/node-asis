--==============================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetFeriado]
-- Fecha:  27-09-2025
-- Descripcion: Procedimiento para mostrar todos los registros de la tablas 
-- DenominacionFeriado
--==============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_GetFeriado]

AS
BEGIN
    SELECT id, codigo, cDenominacion AS denominacion, cDescripcion AS descripcion
    FROM DenominacionFeriado
    WHERE bEliminado = 0
END
GO