/*======================================================================================================
NOMBRE: [dbo].[usp_getHorariosPorRolUsuarioId]
FECHA: 20/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los horarios de un usuario a partir de su RolUsuarioId y genear asistencia a partir
del horario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getHorariosPorRolUsuarioId]
  @HORARIO_ID INT,
  @ROL_USUARIO_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @DatosAsistencia TABLE
        (
    horarioId INT,
    horario NVARCHAR(100),
    dia NVARCHAR(50),
    turnoEntradaId INT,
    horaEntrada TIME,
    turnoSalidaId INT,
    horaSalida TIME,
    tipoTurno NVARCHAR(50),
    diaLibre NVARCHAR(2),
    conectadoDiaId INT,
    vigenciaInicio DATE,
    vigenciaFin DATE
        );

  DECLARE @Dia NVARCHAR(50) = FORMAT(GETDATE(), 'dddd', 'es-ES');
  DECLARE @DiaAnterior NVARCHAR(50) = FORMAT(DATEADD(DAY, -1, GETDATE()), 'dddd', 'es-ES');

  WITH
    TurnosNumerados
    AS
    (
      SELECT
        h.id AS horarioId,
        h.cTitulo AS horario,
        d.cTitulo AS dia,
        d.id AS diaId,
        hd.bLibre,
        tr.id AS turnoRegularId,
        tr.horaInicio AS horaTurnoRegular,
        te.id AS turnoExtendidoId,
        te.horaInicio AS horaTurnoExtendido,
        te.horaFin AS horaFinTurnoExtendido,
        -- Identificar tipo de turno
        CASE 
                WHEN te.id IS NOT NULL THEN 'Extendido'
                WHEN tr.id IS NOT NULL THEN 'Regular'
                ELSE NULL
              END AS tipoTurno,
        -- Numerar los turnos regulares por día
        ROW_NUMBER() OVER (PARTITION BY hd.id ORDER BY COALESCE(tr.horaInicio, te.horaInicio)) AS numeroTurno,
        cd.diasId_pk AS conectadoDiaId,
        v.tFechaInicio AS vigenciaInicio,
        v.tFechaFin AS vigenciaFin
      FROM Horario h
        INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
        INNER JOIN Dia d ON d.id = hd.diaId_fk
        LEFT JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id
        LEFT JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id
        LEFT JOIN ConectadoDias cd on cd.turnoExtendidoId_pk = te.id
        LEFT JOIN Vigencia v on v.horarioDiasId_fk = hd.id and v.bActivo = 1
      WHERE h.id = @HORARIO_ID
    ),
    TurnosEmparejados
    AS
    (
      SELECT
        t1.horarioId,
        t1.horario,
        t1.dia,
        t1.diaId,
        t1.bLibre,
        -- Turno de entrada
        COALESCE(t1.turnoRegularId, t1.turnoExtendidoId) AS turnoEntradaId,
        COALESCE(t1.horaTurnoRegular, t1.horaTurnoExtendido) AS horaEntrada,
        -- Turno de salida
        COALESCE(t2.turnoRegularId, t1.turnoExtendidoId) AS turnoSalidaId,
        COALESCE(t2.horaTurnoRegular, t1.horaFinTurnoExtendido) AS horaSalida,
        -- Tipo de turno
        t1.tipoTurno,
        t1.conectadoDiaId,
        t1.vigenciaInicio,
        t1.vigenciaFin
      FROM TurnosNumerados t1
        LEFT JOIN TurnosNumerados t2
        ON t1.diaId = t2.diaId
          AND t1.numeroTurno % 2 = 1 -- Solo turnos impares (entrada)
          AND t2.numeroTurno = t1.numeroTurno + 1
      -- El siguiente turno (salida)
      WHERE t1.numeroTurno % 2 = 1 OR t1.turnoExtendidoId IS NOT NULL
    )

  INSERT INTO @DatosAsistencia
    (
    horarioId,
    horario,
    dia,
    turnoEntradaId,
    horaEntrada,
    turnoSalidaId,
    horaSalida,
    tipoTurno,
    diaLibre,
    conectadoDiaId,
    vigenciaInicio,
    vigenciaFin
    )
  SELECT
    horarioId,
    horario,
    dia,
    turnoEntradaId,
    horaEntrada,
    turnoSalidaId,
    horaSalida,
    tipoTurno,
    CASE WHEN bLibre = 1 THEN 'SI' ELSE 'NO' END AS diaLibre,
    conectadoDiaId,
    vigenciaInicio,
    vigenciaFin
  FROM TurnosEmparejados
  WHERE             
            (turnoEntradaId IS NOT NULL OR bLibre = 1)
    AND dia COLLATE SQL_Latin1_General_CP1_CI_AI = @Dia AND turnoEntradaId IS NOT NULL
    OR ( dia COLLATE SQL_Latin1_General_CP1_CI_AI = @DiaAnterior and tipoTurno = 'Extendido');

  INSERT INTO Asistencia
    (horaEntrada, horaSalida, vigenciaFin, vigenciaInicio, rolUsuarioid_fk, tFecha, tCreatedAt, turnoEntradaid, turnoSalidaid, nCreatedBy, esRegular)
  SELECT
    d.horaEntrada,
    d.horaSalida,
    d.vigenciaFin,
    d.vigenciaInicio,
    @ROL_USUARIO_ID, -- RolUsuarioId
    CAST(GETDATE() AS DATE),
    GETDATE(),
    d.turnoEntradaId,
    d.turnoSalidaId,
    1,
    CASE WHEN d.conectadoDiaId is not null then 0 else 1 end as esRegular
  FROM @DatosAsistencia d
  WHERE NOT EXISTS (
            SELECT 1
  FROM Asistencia a
  WHERE a.rolUsuarioid_fk = @ROL_USUARIO_ID
    AND ISNULL(a.turnoEntradaid, -1) = ISNULL(d.turnoEntradaId, -1)
    AND ISNULL(a.turnoSalidaid, -1) = ISNULL(d.turnoSalidaId, -1)
    AND a.tFecha = CAST(GETDATE() AS DATE)
          );

  SELECT
    id,
    horaEntrada,
    horaSalida,
    vigenciaFin,
    vigenciaInicio,
    turnoEntradaid,
    turnoSalidaid,
    tFecha,
    rolUsuarioid_fk rolUsuarioId,
    esRegular
  FROM Asistencia
  WHERE rolUsuarioid_fk = @ROL_USUARIO_ID AND tFecha = CAST(GETDATE() AS DATE);

END