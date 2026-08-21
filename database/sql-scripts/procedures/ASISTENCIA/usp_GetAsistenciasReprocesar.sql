/*======================================================================================================
NOMBRE: [dbo].[usp_GetAsistenciasReprocesar]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Devolver dos resultsets para el reprocesador:
           RS1: asistencias existentes con sus marcaciones y control snapshot.
           RS2: turnos vigentes sin asistencia, ya terminados, con control, guard y feriado aplicables.
           Si @Fecha es NULL se usa la fecha actual para el barrido de cierre.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
   1  21-08-2026  Gabriel    Agrega control, guard, feriado y turno modificado al barrido de cierre.
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetAsistenciasReprocesar]
    @UsuarioId INT = NULL,
    @Fecha DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- RS1: asistencias existentes + marcaciones enlazadas
    SELECT
        A.AsistenciaId AS asistenciaId,
        A.UsuarioId AS usuarioId,
        A.Fecha AS fecha,
        A.EstadoAsistenciaEntradaId AS estadoEntradaId,
        A.EstadoAsistenciaSalidaId AS estadoSalidaId,
        A.ResultadoAsistencia AS resultadoAsistencia,
        A.ControlId AS controlId,
        A.HoraEntrada AS horaEntrada,
        A.HoraSalida AS horaSalida,
        A.vigenciaInicio AS vigenciaInicio,
        A.vigenciaFin AS vigenciaFin,
        A.turnoEntrada AS turnoEntrada,
        A.turnoId AS turnoId,
        A.turnoSalida AS turnoSalida,
        C.Tolerancia AS tolerancia,
        C.LimiteTardanza AS limiteTardanza,
        AM.AsistenciaMarcacionId AS asistenciaMarcacionId,
        AM.MarcacionId AS marcacionId,
        AM.TipoMarcacion AS tipoMarcacion,
        M.PunchTime AS punchTime
    FROM Asistencia A
    LEFT JOIN [Control] C ON C.ControlId = A.ControlId AND C.Eliminado = 0
    LEFT JOIN AsistenciaMarcacion AM ON AM.AsistenciaId = A.AsistenciaId
    LEFT JOIN Marcacion M ON M.MarcacionId = AM.MarcacionId
    WHERE (@UsuarioId IS NULL OR A.UsuarioId = @UsuarioId)
        AND (@Fecha IS NULL OR A.Fecha = @Fecha);

    -- RS2: turnos vigentes sin asistencia, ya terminados (candidatos a Falta)
    DECLARE @DiaBarrido DATE = ISNULL(@Fecha, CAST(GETDATE() AS DATE));
    DECLARE @DiaSemana INT = ((DATEPART(dw, @DiaBarrido) + @@DATEFIRST + 5) % 7) + 1;

    SELECT
        HA.UsuarioId AS usuarioId,
        @DiaBarrido AS fecha,
        T.TurnoId AS turnoId,
        HD.HorarioDiaId AS horarioDiaId,
        COALESCE(TM.HoraInicio, T.HoraInicio) AS horaInicio,
        COALESCE(TM.HoraFin, T.HoraFin) AS horaFin,
        T.Extendido AS extendido,
        HD.DiaId AS diaIdEntrada,
        STD.DiaId AS salidaDiaId,
        C.ControlId AS controlId,
        C.Tolerancia AS tolerancia,
        C.LimiteTardanza AS limiteTardanza,
        G.tipoGuard AS tipoGuard,
        CONVERT(BIT, CASE WHEN F.FeriadoId IS NULL THEN 0 ELSE 1 END) AS feriadoAplicable
    FROM HorarioAsignacion HA
    INNER JOIN Horario H ON H.HorarioId = HA.HorarioId AND H.Eliminado = 0
    INNER JOIN HorarioDia HD ON HD.HorarioId = H.HorarioId AND HD.Eliminado = 0 AND HD.DiaId = @DiaSemana
    INNER JOIN Turno T ON T.HorarioDiaId = HD.HorarioDiaId AND T.Eliminado = 0
    LEFT JOIN SalidaTurnoDia STD ON STD.TurnoId = T.TurnoId AND STD.Eliminado = 0
    OUTER APPLY (
        SELECT TOP 1 TM.HoraInicio, TM.HoraFin
        FROM TurnoModificado TM
        WHERE TM.TurnoId = T.TurnoId
          AND TM.UsuarioId = HA.UsuarioId
          AND TM.Fecha = @DiaBarrido
          AND TM.Eliminado = 0
    ) TM
    OUTER APPLY (
        SELECT TOP 1 C0.ControlId, C0.Tolerancia, C0.LimiteTardanza
        FROM (
            SELECT CU.ControlId, 1 AS Prioridad
            FROM ControlUsuario CU
            WHERE CU.UsuarioId = HA.UsuarioId AND CU.Eliminado = 0
            UNION ALL
            SELECT CA.ControlId, 2
            FROM ControlArea CA
            WHERE CA.AreaId = H.AreaId AND CA.Eliminado = 0
            UNION ALL
            SELECT CUN.ControlId, 3
            FROM ControlUnidad CUN
            WHERE CUN.UnidadId = A.UnidadId AND CUN.Eliminado = 0
        ) X
        INNER JOIN [Control] C0 ON C0.ControlId = X.ControlId AND C0.Eliminado = 0
        ORDER BY X.Prioridad
    ) C
    OUTER APPLY (
        SELECT TOP 1 G0.tipoGuard
        FROM (
            SELECT 'Justificado' AS tipoGuard, 1 AS Prioridad
            FROM Justificaciones J
            WHERE J.UsuarioId = HA.UsuarioId AND J.Fecha = @DiaBarrido
            UNION ALL
            SELECT 'Vacaciones', 2
            FROM Vacaciones V
            INNER JOIN DetalleVacaciones DV ON DV.VacacionId = V.VacacionId AND DV.Eliminado = 0
            WHERE V.UsuarioId = HA.UsuarioId AND V.Aprobado = 1 AND V.Eliminado = 0
              AND @DiaBarrido BETWEEN DV.FechaInicio AND ISNULL(DV.FechaFin, DV.FechaInicio)
            UNION ALL
            SELECT 'Licencia', 3
            FROM Licencia L
            WHERE L.UsuarioId = HA.UsuarioId AND L.Estado = 'Aprobado'
              AND @DiaBarrido BETWEEN L.FechaInicio AND ISNULL(L.FechaFin, L.FechaInicio)
            UNION ALL
            SELECT 'Permiso', 4
            FROM Permisos P
            WHERE P.UsuarioId = HA.UsuarioId AND P.Estado = 'Aprobado'
              AND CAST(P.FechaSolicitud AS DATE) = @DiaBarrido
        ) G0
        ORDER BY G0.Prioridad
    ) G
    OUTER APPLY (
        SELECT TOP 1 F0.FeriadoId
        FROM Feriado F0
        INNER JOIN FeriadoUnidad FU ON FU.FeriadoId = F0.FeriadoId
            AND FU.UnidadId = A.UnidadId AND FU.Eliminado = 0
        WHERE F0.Fecha = @DiaBarrido AND F0.Estado = 1
    ) F
    WHERE HA.UsuarioId = ISNULL(@UsuarioId, HA.UsuarioId)
        AND HA.Eliminado = 0
        AND HA.Culminacion = 0
        AND HA.FechaInicio <= @DiaBarrido
        AND (HA.FechaFin IS NULL OR HA.FechaFin >= @DiaBarrido)
        AND (
            H.Rotativo = 0
            OR EXISTS (
                SELECT 1 FROM VigenciaGrupo VG
                INNER JOIN HorarioDia HD2 ON HD2.VigenciaGrupoId = VG.VigenciaGrupoId
                WHERE HD2.HorarioDiaId = HD.HorarioDiaId
                    AND VG.Eliminado = 0
                    AND VG.FechaInicio <= @DiaBarrido
                    AND (VG.FechaFin IS NULL OR VG.FechaFin >= @DiaBarrido)
            )
        )
        AND NOT EXISTS (
            SELECT 1 FROM Asistencia A
            WHERE A.UsuarioId = HA.UsuarioId AND A.Fecha = @DiaBarrido AND A.turnoId = T.TurnoId
        )
        AND (
            -- el turno ya termino (HoraFin + 1 dia si extendido)
            (T.Extendido = 0 AND DATEADD(
                MINUTE,
                DATEDIFF(MINUTE, CAST('00:00:00' AS TIME), T.HoraFin),
                CAST(@DiaBarrido AS DATETIME2)
            ) <= GETDATE())
            OR
            (T.Extendido = 1 AND DATEADD(
                MINUTE,
                DATEDIFF(MINUTE, CAST('00:00:00' AS TIME), T.HoraFin),
                DATEADD(DAY, 1, CAST(@DiaBarrido AS DATETIME2))
            ) <= GETDATE())
        );
END
GO
