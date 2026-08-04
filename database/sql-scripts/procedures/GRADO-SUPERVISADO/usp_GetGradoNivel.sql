--===================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetGradoNivel]
-- Fecha: 22-10-2025
-- Descripcion: Procedimiento listar los Grados por nivel
--====================================================================================
CREATE OR ALTER PROCEDURE [dbo].[usp_GetGradoNivel]

AS
BEGIN
    SELECT idGrado as idGrado ,cGrado AS grado, cNivel AS nivel
    FROM Sync_GradoNivel 
END