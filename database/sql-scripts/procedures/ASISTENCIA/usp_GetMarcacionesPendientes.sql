/*======================================================================================================
NOMBRE: [dbo].[usp_GetMarcacionesPendientes]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Listar marcaciones aun no enlazadas en AsistenciaMarcacion, resolviendo el UsuarioId por
          DNI (EmpCode = SyncUsuarios.Dni). Filtros opcionales de usuario y fecha. UsuarioId puede
          venir NULL (sin match de DNI).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetMarcacionesPendientes]
    @UsuarioId INT = NULL,
    @Fecha DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        M.MarcacionId AS marcacionId,
        M.EmpCode AS empCode,
        M.PunchTime AS punchTime,
        M.TerminalId AS terminalId,
        B.BiometricoId AS biometricoId,
        U.UsuarioId AS usuarioId
    FROM Marcacion M
    LEFT JOIN Biometrico B ON B.TerminalId = M.TerminalId AND B.Eliminado = 0
    LEFT JOIN SyncUsuarios S ON S.Dni = M.EmpCode
    LEFT JOIN Usuario U ON U.SyncUsuarioId = S.SyncUsuarioId AND U.Eliminado = 0 AND U.Active = 1
    WHERE M.Eliminado = 0
        AND NOT EXISTS (
            SELECT 1 FROM AsistenciaMarcacion AM
            WHERE AM.MarcacionId = M.MarcacionId
        )
        AND (@UsuarioId IS NULL OR U.UsuarioId = @UsuarioId)
        AND (@Fecha IS NULL OR CAST(M.PunchTime AS DATE) = @Fecha)
    ORDER BY M.PunchTime ASC;
END
GO
