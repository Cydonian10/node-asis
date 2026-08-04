
CREATE OR ALTER PROCEDURE [dbo].[usp_UsuarioByRolId]
  @ROL_ID INT

AS
BEGIN
    SELECT 
        U.id AS usuarioId,
        U.cUsuario AS usuario,
        U.cDni,
        U.cNombre,
        U.cApellido,
        RU.id AS rolUsuarioId,
        RU.rolId_fk AS rolId,
        R.cTitulo AS rol
    FROM Sync_UsuarioPersona AS U
        INNER JOIN RolUsuario AS RU ON U.id = RU.usuarioId_fk
        INNER JOIN Rol AS R ON RU.rolId_fk = R.id
    WHERE RU.rolId_fk = @ROL_ID
        AND RU.bEliminado = 0
    ORDER BY U.cUsuario ASC
END
GO

