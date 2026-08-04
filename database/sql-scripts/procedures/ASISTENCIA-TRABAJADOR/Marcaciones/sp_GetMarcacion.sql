SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetMarcacion]
-- Fecha:  18-09-2025
-- Descripcion: Procedimiento para mostrar todos los registros de marcacion
-- Parámetros: 'EMPLEADOID','EMPLEADOCOD','PUNCHSTATE', 'TERMINALID'
-- 'TERMINALSN', 'TERMINALALIAS', TERMINALAlIAS
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_GetMarcacion]
AS
BEGIN
     SELECT M.id,
     emp_code AS Codigo_Empleado,
     U.cNombre AS nombre,
     u.cApellido as apellido,
     punch_time AS Tiempo_Marcacion,
     punch_state AS Estado_Marcacion,
     terminal_sn AS Numero_Serie,
     terminal_alias AS Nombre_Terminal,
     emp_id,
     terminal_id
     FROM Marcacion AS M
     INNER JOIN Sync_Usuario AS U ON M.emp_id = u.id 
      WHERE bEliminado = 0
      ORDER BY Tiempo_Marcacion DESC
END
GO
