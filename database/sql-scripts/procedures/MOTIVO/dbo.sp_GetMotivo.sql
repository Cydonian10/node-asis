--==============================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetMotivo]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para mostrar todos los registro de Motivo que no esten eliminados
-- Parámetros: 'ID', NOMBRE', 'DETALLE', 'EN USO'
--==============================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_GetMotivo]
AS
BEGIN
    SELECT id, nombre, detalle,
        CASE 
        WHEN EXISTS( SELECT 1
        FROM Justificacion
        WHERE motivoId_fk = id AND bEliminado = 0) THEN 1
        WHEN EXISTS( SELECT 1
        FROM Permiso
        WHERE motivoId_fk = id AND bEliminado = 0) THEN 1
        WHEN EXISTS( SELECT 1
        FROM Licencia
        WHERE motivoId_fk = id AND bEliminado = 0) THEN 1
        ELSE 0
    END as uso,
        bDocumento as documento
    FROM Motivo
    WHERE bEliminado = 0
END
GO
