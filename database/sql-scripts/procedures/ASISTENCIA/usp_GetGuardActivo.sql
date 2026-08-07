/*======================================================================================================
NOMBRE: [dbo].[usp_GetGuardActivo]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Determinar si el dia @Fecha esta cubierto por algun guard para el usuario. Prioridad:
          Justificado > Vacaciones > Licencia > Permiso (primer match). Devuelve TipoGuard o vacio.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetGuardActivo]
    @UsuarioId INT,
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1 GuardTipo AS tipoGuard
    FROM (
        SELECT 1 AS Prioridad, 'Justificado' AS GuardTipo
        FROM Justificaciones J
        WHERE J.UsuarioId = @UsuarioId AND J.Fecha = @Fecha

        UNION ALL

        SELECT 2, 'Vacaciones'
        FROM Vacaciones V
        INNER JOIN DetalleVacaciones DV ON DV.VacacionId = V.VacacionId AND DV.Eliminado = 0
        WHERE V.UsuarioId = @UsuarioId AND V.Aprobado = 1 AND V.Eliminado = 0
            AND @Fecha BETWEEN DV.FechaInicio AND ISNULL(DV.FechaFin, DV.FechaInicio)

        UNION ALL

        SELECT 3, 'Licencia'
        FROM Licencia L
        WHERE L.UsuarioId = @UsuarioId
            AND L.Estado = 'Aprobado'
            AND @Fecha BETWEEN L.FechaInicio AND ISNULL(L.FechaFin, L.FechaInicio)

        UNION ALL

        SELECT 4, 'Permiso'
        FROM Permisos P
        WHERE P.UsuarioId = @UsuarioId
            AND P.Estado = 'Aprobado'
            AND CAST(P.FechaSolicitud AS DATE) = @Fecha
    ) G
    ORDER BY G.Prioridad ASC;
END
GO
