--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetOneTurnoModificado]
-- Fecha:  22-09-2025
-- Descripcion: Procedimiento para mostrar un registro de turno Modificado
-- Parámetros: 'ID'
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_GetOneTurnoModificado]
    @ID INT
AS 
BEGIN
  SELECT tm.id, 
    Usuario = CASE
        WHEN tm.rolUsuarioId_fk IS NULL THEN 'Todos los usuarios'
        END, 
        tr.id as id_Turno_Regular, tr.horaInicio, tm.tHora AS HoraModificada,
    Tipo = CASE
        WHEN tm.bTipo = 0 THEN 'Entrada'
        WHEN tm.bTipo = 1 THEN 'Salida'
    END,
     tm.fechaInicio, tm.fechaFin
    FROM TurnoModificado AS tm 
    INNER JOIN TurnoRegular AS tr ON tm.turnoRegularId_fk = tr.id
  WHERE tm.id = @ID AND tm.bEliminado = 0
END
GO