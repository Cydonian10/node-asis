--=================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetAsistenciaModificada]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para mostrar todos los registros que 
-- no esten eliminados de asistencia modificada 
-- a partir de:
-- 'Detalle biomtrico', 'Turno Modificado', 'Marcaciones' 'Asistencia'
--=================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_GetAsistenciaModificada]

AS
BEGIN 
    SELECT am.id
    ,db.cNombre as biometrico
    ,db.ubicacion
    ,tm.tHora as hora
    ,tm.btipo as tipo
    ,a.tFecha as fecha
    ,m.id as idMarcacion
    ,U.cUsuario AS usuario
    ,U.cNombre AS nombre
    ,RU.usuarioId_fk AS id_usuario
    FROM AsistenciaModificada AS am
    INNER JOIN  DetalleBiometrico AS db ON am.detalleBiometricoId_fk = db.id
    INNER JOIN  TurnoModificado AS tm ON am.turnoModificadoId_fk = tm.id
    INNER JOIN  Asistencia AS a ON am.asistenciaId_fk = a.id
    INNER JOIN  Marcacion AS m ON am.marcacionId_fk = m.id
    INNER JOIN Sync_Usuario U ON M.emp_id = U.id
    INNER JOIN RolUsuario RU ON U.id = RU.usuarioId_fk
    WHERE am.bEliminado =  0;
END 
GO