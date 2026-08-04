--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetManyHorioDias]
-- Fecha:  17-09-2025
-- Descripcion: Procedimiento para mostrar todos los registros de horarioDia
--=========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[usp_GetManyHorarioDias]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        h.id AS Id_Horario, hd.id, h.cTitulo AS Nombre_Horario,
        d.cTitulo AS Dia,
        libre = CASE 
  WHEN  bLibre = 1 THEN 'si'
  WHEN  bLibre = 0 THEN 'No'
  END,
        hd.bEliminado, v.tfechaInicio, v.tfechaFin
    FROM HorarioDias AS hd
        INNER JOIN Horario AS h ON hd.horarioId_fk = h.id
        INNER JOIN Dia AS d ON hd.diaId_fk = d.id
        LEFT JOIN Vigencia AS v ON v.horarioDiasId_fk = hd.id
        WHERE hd.bEliminado = 0

END
GO
