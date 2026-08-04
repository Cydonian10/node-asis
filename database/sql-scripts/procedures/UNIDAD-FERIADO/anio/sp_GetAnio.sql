CREATE OR ALTER PROCEDURE [dbo].[sp_GetAnio]

AS
BEGIN
    SELECT id, cDenominacion AS denominacion, cDescripcion AS descripcion
    FROM Sync_Anio
END
GO 