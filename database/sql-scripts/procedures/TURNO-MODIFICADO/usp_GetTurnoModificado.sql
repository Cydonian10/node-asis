--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetTurnoModfificado]
-- Fecha:  22-09-2025
-- Descripcion: Procedimiento para mostrar todos los registros de turno Modificado 
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_GetTurnoModfificado]

AS
BEGIN
    SELECT tm.id, usuario = CASE
        WHEN tm.rolUsuarioId_fk IS NULL THEN 'Todos los usuarios'
        ELSE CAST(tm.rolUsuarioId_fk AS varchar(10))
      
    END,
        tr.id as turnoRegularId,
        CAST(tr.horaInicio AS VARCHAR(5)) AS horaInicio,
        CAST(tm.tHora AS VARCHAR(5)) AS hora,
        tipo = CASE
        WHEN tm.bTipo = 0 THEN 'Entrada'
        WHEN tm.bTipo = 1 THEN 'Salida'
    END,
        tm.fechaInicio,
        tm.fechaFin,
        su.cNombre as nombre,
        su.cApellido as apellido,
        ru.id as idRolUsuario,
        d.cTitulo as dia,
        h.cTitulo as horario
    FROM TurnoModificado AS tm
        INNER JOIN TurnoRegular AS tr ON tm.turnoRegularId_fk = tr.id
        LEFT JOIN RolUsuario AS ru ON tm.rolUsuarioId_fk = ru.id
        LEFT JOIN Sync_Usuario as su ON ru.usuarioId_fk = su.id
        LEFT JOIN HorarioDias AS hd ON tr.horarioDiasId_fk = hd.id
        LEFT JOIN Dia AS d ON hd.diaId_fk = d.id
        LEFT JOIN Horario AS h ON hd.horarioId_fk = h.id
    WHERE tm.bEliminado = 0
    ORDER BY  tm.id DESC
END
GO