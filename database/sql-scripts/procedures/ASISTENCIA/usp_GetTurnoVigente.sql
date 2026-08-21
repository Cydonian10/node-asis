/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoVigente]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Obtener el turno vigente mas cercano a una hora para (Usuario, Fecha). Considera dos modos:
          - entrada-match: HorarioDia.DiaId = dia de la semana de @Fecha (el dia del turno).
          - salida-match (solo turnos extendidos): SalidaTurnoDia.DiaId = dia de la semana de @Fecha,
            dentro de una ventana de < 1 semana desde el dia de entrada.
          En horarios rotativos el HorarioDia debe pertenecer a un VigenciaGrupo cuyo rango contenga
          @Fecha. Ordena por distancia a @Hora. esEntradaMatch indica si la marca corresponde a la
          entrada.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  1  14-08-2026  Gabriel    Modelo grupos de vigencia (VigenciaGrupo en vez de Vigencia por dia).
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
        H.AreaId AS areaId,
        A.UnidadId AS unidadId,
        COALESCE(TM.HoraInicio, T.HoraInicio) AS horaInicio,
        COALESCE(TM.HoraFin, T.HoraFin) AS horaFin,
        T.Extendido AS extendido,
        HD.DiaId AS diaIdEntrada,
        STD.DiaId AS salidaDiaId,
        VG.VigenciaGrupoId AS vigenciaGrupoId,
        VG.FechaInicio AS fechaInicio,
        VG.FechaFin AS fechaFin,
        CASE WHEN HD.DiaId = @DiaSemana THEN 1 ELSE 0 END AS esEntradaMatch,
        ABS(DATEDIFF(MINUTE,
            CASE
                WHEN HD.DiaId = @DiaSemana THEN COALESCE(TM.HoraInicio, T.HoraInicio)
                ELSE COALESCE(TM.HoraFin, T.HoraFin)
            END,
            @Hora)) AS distancia
    FROM HorarioAsignacion HA
    INNER JOIN Horario H ON H.HorarioId = HA.HorarioId AND H.Eliminado = 0
    INNER JOIN Area A ON A.AreaId = H.AreaId AND A.Eliminado = 0
    INNER JOIN HorarioDia HD ON HD.HorarioId = H.HorarioId AND HD.Eliminado = 0
    INNER JOIN Turno T ON T.HorarioDiaId = HD.HorarioDiaId AND T.Eliminado = 0
    LEFT JOIN SalidaTurnoDia STD ON STD.TurnoId = T.TurnoId AND STD.Eliminado = 0
    LEFT JOIN VigenciaGrupo VG ON VG.VigenciaGrupoId = HD.VigenciaGrupoId AND VG.Eliminado = 0
        AND VG.FechaInicio <= @Fecha AND (VG.FechaFin IS NULL OR VG.FechaFin >= @Fecha)
    OUTER APPLY (
        SELECT TOP 1 TM.HoraInicio, TM.HoraFin
        FROM TurnoModificado TM
        WHERE TM.TurnoId = T.TurnoId
          AND TM.UsuarioId = HA.UsuarioId
          AND TM.Fecha = CASE
              WHEN HD.DiaId = @DiaSemana THEN @Fecha
              ELSE DATEADD(DAY, -((@DiaSemana - HD.DiaId + 7) % 7), @Fecha)
          END
          AND TM.Eliminado = 0
    ) TM
    WHERE HA.UsuarioId = @UsuarioId
        AND HA.Eliminado = 0
        AND HA.Culminacion = 0
        AND HA.FechaInicio <= @Fecha
        AND (HA.FechaFin IS NULL OR HA.FechaFin >= @Fecha)
        AND (
            HD.DiaId = @DiaSemana
            OR (T.Extendido = 1 AND STD.DiaId = @DiaSemana)
        )
        AND (
            H.Rotativo = 0
            OR VG.VigenciaGrupoId IS NOT NULL
        )
    ORDER BY distancia ASC, T.TurnoId ASC;
END
GO
