SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetOneMarcacion]
-- Fecha:  18-09-2025
-- Descripcion: Procedimiento para mostrar un registro de marcacion a partir de ID
-- Parámetros: 'EMPLEADOID','EMPLEADOCOD','PUNCHSTATE', 'TERMINALID'
-- 'TERMINALSN', 'TERMINALALIAS', TERMINALAlIAS
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_GetOneMarcacion]
    @ID INT
AS
BEGIN 
    SELECT id,
     emp_code AS codigoEmpleado,
     punch_time AS TiempoMarcacion,
     punch_state AS EstadoMarcacion,
     terminal_sn,
     terminal_alias,
     emp_id AS Id_Usuario,
     terminal_id
    FROM Marcacion 
    WHERE id = @ID AND bEliminado = 0
END
GO
