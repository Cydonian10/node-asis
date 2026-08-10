/*======================================================================================================
NOMBRE: [dbo].[usp_GetAsistenciasReprocesar]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Devolver dos resultsets para el reprocesador:
          RS1: asistencias existentes con sus marcaciones (re-evaluar estados/resultado).
          RS2: turnos vigentes SIN asistencia para el dia cuyos turnos ya terminaron (candidatos a
               Falta). Si @Fecha es NULL se usa la fecha actual para el barrido de Falta.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
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
        AM.AsistenciaMarcacionId AS asistenciaMarcacionId,
        AM.MarcacionId AS marcacionId,
        AM.TipoMarcacion AS tipoMarcacion,
        M.PunchTime AS punchTime
    FROM Asistencia A
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
        T.HoraInicio AS horaInicio,
        T.HoraFin AS horaFin,
        T.Extendido AS extendido,
        HD.DiaId AS diaIdEntrada,
        STD.DiaId AS salidaDiaId
    FROM HorarioAsignacion HA
    INNER JOIN Horario H ON H.HorarioId = HA.HorarioId AND H.Eliminado = 0
    INNER JOIN HorarioDia HD ON HD.HorarioId = H.HorarioId AND HD.Eliminado = 0 AND HD.DiaId = @DiaSemana
    INNER JOIN Turno T ON T.HorarioDiaId = HD.HorarioDiaId AND T.Eliminado = 0
    LEFT JOIN SalidaTurnoDia STD ON STD.TurnoId = T.TurnoId AND STD.Eliminado = 0
    WHERE HA.UsuarioId = ISNULL(@UsuarioId, HA.UsuarioId)
        AND HA.Eliminado = 0
        AND HA.FechaInicio <= @DiaBarrido
        AND (HA.FechaFin IS NULL OR HA.FechaFin >= @DiaBarrido)
        AND (
            H.Rotativo = 0
            OR EXISTS (
                SELECT 1 FROM Vigencia V2
                WHERE V2.HorarioDiaId = HD.HorarioDiaId
                    AND V2.Eliminado = 0
                    AND V2.FechaInicio <= @DiaBarrido
                    AND (V2.FechaFin IS NULL OR V2.FechaFin >= @DiaBarrido)
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
