--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetMarcacionUsuarioId]
-- Fecha:  18-12-2025
-- Descripcion: Procedimiento para listar registros de marcacion por el id de usuario
-- Parámetros: 'ID', 'USUARIO','PUNCHSTATE', 'PUNCHSTIME'
--=======================================================================================

CREATE OR ALTER PROCEDURE [dbo].[usp_GetMarcacionUsuarioId]
    @USUARIO INT

AS
BEGIN
    SELECT
        M.id 
 , RU.id AS rolUsuarioId
 , M.emp_code AS codigoEmpleado
 , M.emp_id AS empleado
, U.cUsuario as syncUsuario
, RU.usuarioId_fk as rol_usuarioid
 , M.punch_state as estado
 , M.terminal_id as biometricoId
 , M.terminal_alias as asliasbiometrico
 , DB.cNombre as biometrico
 , M.punch_time as tiempoMarcacion
    FROM Marcacion AS M
        INNER JOIN Sync_UsuarioPersona AS U ON  M.emp_id = U.id
        INNER JOIN RolUsuario AS RU ON U.id = RU.usuarioId_fk
        INNER JOIN DetalleBiometrico AS DB ON M.terminal_id = DB.id
            AND M.bEliminado = 0
            AND RU.bEliminado = 0
    WHERE M.emp_id = @USUARIO
    ORDER BY 
        M.punch_time DESC
END
GO
