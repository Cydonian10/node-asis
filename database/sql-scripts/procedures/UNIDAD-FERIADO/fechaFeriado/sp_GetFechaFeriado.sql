--==============================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetFechaFeriado]
-- Fecha:  01-10-2025
-- Descripcion: Procedimiento para mostrar todos los registros de Fecha feriado

--==============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_GetFechaFeriado]

AS 
BEGIN
    SET NOCOUNT ON;

    SELECT f.id, df.cDenominacion AS feriado, f.fecha, a.cDenominacion AS anio
    FROM FechaFeriado AS f
    INNER JOIN Sync_Anio AS a ON f.anioId_fk = a.id
    INNER JOIN DenominacionFeriado AS df ON f.denominacionFeriadoId_fk = df.id 
    WHERE f.bEliminado = 0 
END

SELECT * FROM FechaFeriado