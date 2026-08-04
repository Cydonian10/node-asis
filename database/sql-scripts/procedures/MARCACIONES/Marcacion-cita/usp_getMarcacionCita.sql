CREATE OR ALTER PROCEDURE [dbo].[usp_GetMarcacionCitas]
    @USUARIO INT
AS
BEGIN
    SELECT
        C.id AS citaId,
        U.cNombre AS usuario,
        C.horarioUsuarioId_fk as horarioUsuarioId,
        C.cDescripcion AS descripcion,
        C.fecha AS fecha,
        C.hora AS hora,
        M.punch_time AS fechaMarcacion,
        M.punch_state
    FROM Cita AS C
        INNER JOIN HorarioUsuario HU ON C.horarioUsuarioId_fk = HU.id
        INNER JOIN RolUsuario RU ON HU.rolUsuarioId_fk = RU.id
        INNER JOIN Sync_Usuario U ON RU.usuarioId_fk = U.id
        INNER JOIN Marcacion M ON U.id = M.emp_id
    WHERE 
    U.id = @USUARIO
        AND CAST(M.punch_time AS DATE) = CAST(C.fecha AS DATE)
        AND C.bCancelado = 0;

END 
GO