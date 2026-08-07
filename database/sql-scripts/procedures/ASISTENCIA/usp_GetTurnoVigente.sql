/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoVigente]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Obtener el turno vigente mas cercano a una hora para (Usuario, Fecha). Considera dos modos:
          - entrada-match: HorarioDia.DiaId = dia de la semana de @Fecha (el dia del turno).
          - salida-match (solo turnos extendidos): SalidaTurnoDia.DiaId = dia de la semana de @Fecha,
            dentro de una ventana de < 1 semana desde el dia de entrada.
          Ordena por distancia a @Hora. esEntradaMatch indica si la marca corresponde a la entrada.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_GetTurnoVigente]
    @UsuarioId INT,
    @Fecha DATE,
    @Hora TIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DiaSemana INT;
    -- 1 = Lunes ... 7 = Domingo (independiente de @@DATEFIRST)
    SET @DiaSemana = ((DATEPART(dw, @Fecha) + @@DATEFIRST + 5) % 7) + 1;

    SELECT TOP 1
        T.TurnoId AS turnoId,
        HD.HorarioDiaId AS horarioDiaId,
        T.HoraInicio AS horaInicio,
        T.HoraFin AS horaFin,
        T.Extendido AS extendido,
        HD.DiaId AS diaIdEntrada,
        STD.DiaId AS salidaDiaId,
        V.VigenciaId AS vigenciaId,
        V.FechaInicio AS fechaInicio,
        V.FechaFin AS fechaFin,
        CASE WHEN HD.DiaId = @DiaSemana THEN 1 ELSE 0 END AS esEntradaMatch,
        ABS(DATEDIFF(MINUTE,
            CASE WHEN HD.DiaId = @DiaSemana THEN T.HoraInicio ELSE T.HoraFin END,
            @Hora)) AS distancia
    FROM HorarioAsignacion HA
    INNER JOIN Horario H ON H.HorarioId = HA.HorarioId AND H.Eliminado = 0
    INNER JOIN HorarioDia HD ON HD.HorarioId = H.HorarioId AND HD.Eliminado = 0
    INNER JOIN Turno T ON T.HorarioDiaId = HD.HorarioDiaId AND T.Eliminado = 0
    LEFT JOIN SalidaTurnoDia STD ON STD.TurnoId = T.TurnoId AND STD.Eliminado = 0
    LEFT JOIN Vigencia V ON V.HorarioDiaId = HD.HorarioDiaId AND V.Eliminado = 0
        AND V.FechaInicio <= @Fecha AND (V.FechaFin IS NULL OR V.FechaFin >= @Fecha)
    WHERE HA.UsuarioId = @UsuarioId
        AND HA.Eliminado = 0
        AND HA.FechaInicio <= @Fecha
        AND (HA.FechaFin IS NULL OR HA.FechaFin >= @Fecha)
        AND (
            HD.DiaId = @DiaSemana
            OR (T.Extendido = 1 AND STD.DiaId = @DiaSemana)
        )
        AND (
            H.Rotativo = 0
            OR EXISTS (
                SELECT 1 FROM Vigencia V2
                WHERE V2.HorarioDiaId = HD.HorarioDiaId
                    AND V2.Eliminado = 0
                    AND V2.FechaInicio <= @Fecha
                    AND (V2.FechaFin IS NULL OR V2.FechaFin >= @Fecha)
            )
        )
    ORDER BY distancia ASC, T.TurnoId ASC;
END
GO
