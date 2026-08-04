/*======================================================================================================
NOMBRE: [dbo].[usp_insertControlRolUsuarioAsistencia]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar o actualizar el control de rol de usuario para la asistencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getTurnoRegularOExtendido]
  @ROL_USUARIO_ID INT,
  @FECHA DATETIME2(0),
  @HORA DATETIME2(0)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @turnoRegularId INT = NULL, @turnoExtendidoId INT = NULL;

  -- Buscar turno regular por hora de entrada
  WITH
    FechaHora
    AS
    (
      SELECT
        CAST(@FECHA AS DATE) AS fecha,
        CAST(@HORA AS TIME) AS horaEntrada,
        CASE DATEPART(WEEKDAY, CAST(@FECHA AS DATE))
              WHEN 1 THEN 'Domingo'
              WHEN 2 THEN 'Lunes'
              WHEN 3 THEN 'Martes'
              WHEN 4 THEN 'Miércoles'
              WHEN 5 THEN 'Jueves'
              WHEN 6 THEN 'Viernes'
              WHEN 7 THEN 'Sábado'
            END AS diaNombre
    )
  SELECT
    @turnoRegularId = tr.id,
    @turnoExtendidoId = te.id
  FROM FechaHora fh
    INNER JOIN HorarioUsuario hu ON hu.rolUsuarioId_fk = @ROL_USUARIO_ID AND hu.bEliminado = 0
    INNER JOIN HorarioDias hd ON hd.horarioId_fk = hu.horarioId_fk AND hd.bEliminado = 0
      AND hd.diaId_fk = (SELECT d.id
      FROM Dia d
      WHERE d.cTitulo = fh.diaNombre)
    LEFT JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id AND tr.horaInicio = fh.horaEntrada
    LEFT JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id AND te.horaInicio = fh.horaEntrada;

  -- Si no se encontró turno regular ni extendido, buscar por hora de salida
  IF @turnoRegularId IS NULL AND @turnoExtendidoId IS NULL
        BEGIN
    WITH
      FechaHora
      AS
      (
        SELECT
          CAST(@FECHA AS DATE) AS fecha,
          CAST(@HORA AS TIME) AS horaSalida,
          CASE DATEPART(WEEKDAY, CAST(@FECHA AS DATE))
                WHEN 1 THEN 'Domingo'
                WHEN 2 THEN 'Lunes'
                WHEN 3 THEN 'Martes'
                WHEN 4 THEN 'Miércoles'
                WHEN 5 THEN 'Jueves'
                WHEN 6 THEN 'Viernes'
                WHEN 7 THEN 'Sábado'
              END AS diaNombre
      )
    SELECT
      @turnoRegularId = tr.id,
      @turnoExtendidoId = te.id
    FROM FechaHora fh
      INNER JOIN HorarioUsuario hu ON hu.rolUsuarioId_fk = @ROL_USUARIO_ID AND hu.bEliminado = 0
      INNER JOIN HorarioDias hd ON hd.horarioId_fk = hu.horarioId_fk AND hd.bEliminado = 0
        AND hd.diaId_fk = (SELECT d.id
        FROM Dia d
        WHERE d.cTitulo = fh.diaNombre)
      LEFT JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id AND tr.horaInicio = fh.horaSalida
      LEFT JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id AND te.horaFin = fh.horaSalida;
  END

  SELECT @turnoRegularId AS turnoRegularId, @turnoExtendidoId AS turnoExtendidoId;
END
 