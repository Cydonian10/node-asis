import sql from 'mssql';
import { executeCreate, runTransaction } from '@src/util/sqlServerUtil.js';
import { ErrorUtil } from '@src/util/handleOperationResult.js';
import { ProcesarAsistenciaDto } from './dto/procesar-asistencia.dto.js';
import { ProcesarAsistenciaResultado } from './dto/procesar-asistencia-resultado.dto.js';

// ---------------------------------------------------------------------------
// Tipos de filas que devuelven los SPs
// ---------------------------------------------------------------------------

type UsuarioDniRow = {
  usuarioId: number;
};

type ControlRow = {
  controlId: number;
  tolerancia: number;
  limiteFalta: number;
  limiteTardanza: number;
};

type TurnoVigenteRow = {
  turnoId: number;
  horarioDiaId: number;
  areaId: number;
  unidadId: number;
  horaInicio: string | Date;
  horaFin: string | Date;
  extendido: boolean;
  diaIdEntrada: number;
  salidaDiaId: number | null;
  vigenciaGrupoId: number | null;
  fechaInicio: string | Date | null;
  fechaFin: string | Date | null;
  esEntradaMatch: boolean;
  distancia: number;
};

type GuardRow = {
  tipoGuard: string;
};

type MarcacionPendienteRow = {
  marcacionId: number;
  empCode: string;
  punchTime: Date;
  usuarioId: number | null;
};

type ReprocesarAsistenciaRow = {
  asistenciaId: number;
  usuarioId: number;
  fecha: string | Date;
  estadoEntradaId: number | null;
  estadoSalidaId: number | null;
  resultadoAsistencia: string | null;
  controlId: number | null;
  horaEntrada: Date | null;
  horaSalida: Date | null;
  vigenciaInicio: string | Date | null;
  vigenciaFin: string | Date | null;
  turnoEntrada: string | Date | null;
  turnoId: number | null;
  turnoSalida: string | Date | null;
  asistenciaMarcacionId: number | null;
  marcacionId: number | null;
  tipoMarcacion: string | null;
  punchTime: Date | null;
};

type ReprocesarFaltaRow = {
  usuarioId: number;
  fecha: string | Date;
  turnoId: number;
  horarioDiaId: number;
  horaInicio: string | Date;
  horaFin: string | Date;
  extendido: boolean;
  diaIdEntrada: number;
  salidaDiaId: number | null;
};

type EstadoRow = {
  EstadoAsistenciaId: number;
  Nombre: string;
};

// ---------------------------------------------------------------------------
// Helpers de fecha/hora
// ---------------------------------------------------------------------------

export function normalizeSqlTime(
  value: string | Date | null | undefined,
): Date | null {
  if (value === null || value === undefined) return null;

  if (value instanceof Date) {
    return new Date(
      Date.UTC(
        1970,
        0,
        1,
        value.getUTCHours(),
        value.getUTCMinutes(),
        value.getUTCSeconds(),
        value.getUTCMilliseconds(),
      ),
    );
  }

  const match = /^(\d{2}):(\d{2})(?::(\d{2}))?$/.exec(value);
  if (!match) {
    throw new Error('La hora debe tener formato HH:mm o HH:mm:ss');
  }

  const hours = Number(match[1]);
  const minutes = Number(match[2]);
  const seconds = Number(match[3] ?? '00');
  if (hours > 23 || minutes > 59 || seconds > 59) {
    throw new Error('La hora no es válida');
  }

  return new Date(Date.UTC(1970, 0, 1, hours, minutes, seconds, 0));
}

function pad(n: number): string {
  return n < 10 ? `0${n}` : `${n}`;
}

function isoDate(d: Date): string {
  return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
}

function timeOf(d: Date): string {
  return `${pad(d.getUTCHours())}:${pad(d.getUTCMinutes())}:${pad(d.getUTCSeconds())}`;
}

function timeValue(value: string | Date): string {
  return value instanceof Date ? timeOf(value) : value;
}

function dateValue(value: string | Date): string {
  return value instanceof Date ? isoDate(value) : value;
}

/** DiaId 1=Lunes ... 7=Domingo a partir de una fecha. */
export function weekdayOf(d: Date): number {
  return ((d.getUTCDay() + 6) % 7) + 1;
}

/** Fecha ISO + tiempo como Date. */
function atDateTime(iso: string, time: string | Date): Date {
  return new Date(`${iso}T${timeValue(time)}Z`);
}

/** Siguiente fecha (>= base) cuyo dia de la semana es targetDiaId, barriendo hasta 7 dias. */
export function nextWeekdayIso(baseIso: string, targetDiaId: number): string {
  const base = new Date(`${baseIso}T00:00:00Z`);
  for (let i = 0; i < 7; i++) {
    const d = new Date(base);
    d.setUTCDate(base.getUTCDate() + i);
    if (weekdayOf(d) === targetDiaId) return isoDate(d);
  }
  return baseIso;
}

/** Fecha anterior (<= base) cuyo dia de la semana es targetDiaId, barriendo hasta 7 dias atras. */
export function prevWeekdayIso(baseIso: string, targetDiaId: number): string {
  const base = new Date(`${baseIso}T00:00:00Z`);
  for (let i = 0; i < 7; i++) {
    const d = new Date(base);
    d.setUTCDate(base.getUTCDate() - i);
    if (weekdayOf(d) === targetDiaId) return isoDate(d);
  }
  return baseIso;
}

function diffMinutes(a: Date, b: Date): number {
  return (a.getTime() - b.getTime()) / 60000;
}

// ---------------------------------------------------------------------------
// SPs de consulta (se ejecutan dentro de la transaccion)
// ---------------------------------------------------------------------------

async function getUsuarioByDni(
  tx: sql.Transaction,
  empCode: string,
): Promise<UsuarioDniRow | null> {
  const request = new sql.Request(tx);
  request.input('EmpCode', sql.VarChar(20), empCode);
  const result = await request.execute<UsuarioDniRow>('usp_GetUsuarioByDni');
  return result.recordset[0] ?? null;
}

async function getControlAplicable(
  tx: sql.Transaction,
  usuarioId: number,
  areaId: number,
  unidadId: number,
): Promise<ControlRow | null> {
  const request = new sql.Request(tx);
  request.input('UsuarioId', sql.Int, usuarioId);
  request.input('AreaId', sql.Int, areaId);
  request.input('UnidadId', sql.Int, unidadId);
  const result = await request.execute<ControlRow>('usp_GetControlAplicable');
  return result.recordset[0] ?? null;
}

async function getTurnoVigente(
  tx: sql.Transaction,
  usuarioId: number,
  fecha: string,
  hora: string,
): Promise<TurnoVigenteRow | null> {
  const request = new sql.Request(tx);
  request.input('UsuarioId', sql.Int, usuarioId);
  request.input('Fecha', sql.Date, new Date(`${fecha}T00:00:00`));
  request.input('Hora', sql.Time, normalizeSqlTime(hora));
  const result = await request.execute<TurnoVigenteRow>('usp_GetTurnoVigente');
  return result.recordset[0] ?? null;
}

async function getGuardActivo(
  tx: sql.Transaction,
  usuarioId: number,
  fecha: string,
): Promise<GuardRow | null> {
  const request = new sql.Request(tx);
  request.input('UsuarioId', sql.Int, usuarioId);
  request.input('Fecha', sql.Date, new Date(`${fecha}T00:00:00`));
  const result = await request.execute<GuardRow>('usp_GetGuardActivo');
  return result.recordset[0] ?? null;
}

async function getMarcacionesPendientes(
  tx: sql.Transaction,
  usuarioId?: number,
  fecha?: string,
): Promise<MarcacionPendienteRow[]> {
  const request = new sql.Request(tx);
  request.input('UsuarioId', sql.Int, usuarioId ?? null);
  request.input(
    'Fecha',
    sql.Date,
    fecha ? new Date(`${fecha}T00:00:00`) : null,
  );
  const result = await request.execute<MarcacionPendienteRow>(
    'usp_GetMarcacionesPendientes',
  );
  return result.recordset;
}

async function getEstados(tx: sql.Transaction): Promise<Map<string, number>> {
  const request = new sql.Request(tx);
  const result = await request.query<EstadoRow>(
    'SELECT EstadoAsistenciaId, Nombre FROM EstadoAsistencia WHERE Eliminado = 0',
  );
  const map = new Map<string, number>();
  for (const row of result.recordset) {
    map.set(row.Nombre, row.EstadoAsistenciaId);
  }
  return map;
}

async function getAsistenciaByTurno(
  tx: sql.Transaction,
  usuarioId: number,
  fecha: string,
  turnoId: number,
): Promise<number | null> {
  const request = new sql.Request(tx);
  request.input('UsuarioId', sql.Int, usuarioId);
  request.input('Fecha', sql.Date, new Date(`${fecha}T00:00:00`));
  request.input('TurnoId', sql.Int, turnoId);
  const result = await request.query<{ AsistenciaId: number }>(
    'SELECT AsistenciaId FROM Asistencia WHERE UsuarioId = @UsuarioId AND Fecha = @Fecha AND turnoId = @TurnoId',
  );
  return result.recordset[0]?.AsistenciaId ?? null;
}

/** Actualiza la entrada de una asistencia existente (no hay SP dedicado). */
async function updateEntradaRaw(
  tx: sql.Transaction,
  asistenciaId: number,
  horaEntrada: Date | null,
  estadoEntradaId: number | null,
  resultado: string,
  userId: number,
): Promise<void> {
  const request = new sql.Request(tx);
  request.input('AsistenciaId', sql.Int, asistenciaId);
  request.input('HoraEntrada', sql.DateTime2, horaEntrada);
  request.input('EstadoEntradaId', sql.Int, estadoEntradaId);
  request.input('Resultado', sql.VarChar(50), resultado);
  request.input('USER', sql.Int, userId);
  await request.query(
    `UPDATE Asistencia
     SET HoraEntrada = @HoraEntrada,
         EstadoAsistenciaEntradaId = @EstadoEntradaId,
         ResultadoAsistencia = @Resultado,
         UpdatedAt = GETDATE(),
         UpdatedBy = @USER
     WHERE AsistenciaId = @AsistenciaId`,
  );
}

/** Llena HoraEntrada/HoraSalida de una asistencia de guard sin tocar su resultado. */
async function updateGuardHorasRaw(
  tx: sql.Transaction,
  asistenciaId: number,
  horaEntrada: Date | null,
  horaSalida: Date | null,
  userId: number,
): Promise<void> {
  const request = new sql.Request(tx);
  request.input('AsistenciaId', sql.Int, asistenciaId);
  request.input('HoraEntrada', sql.DateTime2, horaEntrada);
  request.input('HoraSalida', sql.DateTime2, horaSalida);
  request.input('USER', sql.Int, userId);
  await request.query(
    `UPDATE Asistencia
     SET HoraEntrada = ISNULL(@HoraEntrada, HoraEntrada),
         HoraSalida = ISNULL(@HoraSalida, HoraSalida),
         UpdatedAt = GETDATE(),
         UpdatedBy = @USER
     WHERE AsistenciaId = @AsistenciaId`,
  );
}

// ---------------------------------------------------------------------------
// Clasificacion de estados
// ---------------------------------------------------------------------------

export function classificarEntrada(
  estados: Map<string, number>,
  marca: Date,
  entradaTarget: Date,
  tolerancia: number,
  limiteFalta: number,
): number | null {
  const diff = diffMinutes(marca, entradaTarget);
  if (diff <= tolerancia) return estados.get('Asistio') ?? null;
  if (diff <= limiteFalta) return estados.get('Tarde') ?? null;
  return null;
}

export function classificarSalida(
  estados: Map<string, number>,
  marca: Date,
  salidaTarget: Date,
): number | null {
  const diff = diffMinutes(salidaTarget, marca);
  if (diff > 0) return estados.get('SalidaAnticipada') ?? null;
  return estados.get('Asistio') ?? null;
}

function nombreEstado(
  estados: Map<string, number>,
  id: number | null,
): string | null {
  if (id === null || id === undefined) return null;
  for (const [nombre, estadoId] of estados) {
    if (estadoId === id) return nombre;
  }
  return null;
}

export function combinarResultado(
  nombreEntrada: string | null,
  nombreSalida: string | null,
): string {
  if (!nombreEntrada && !nombreSalida) return 'Falta';
  if (nombreEntrada === nombreSalida)
    return nombreEntrada ?? nombreSalida ?? 'Falta';
  return [nombreEntrada, nombreSalida].filter(Boolean).join(' - ');
}

// ---------------------------------------------------------------------------
// procesar-marcaciones
// ---------------------------------------------------------------------------

type GrupoTurno = {
  usuarioId: number;
  areaId: number;
  unidadId: number;
  controlId: number | null;
  tolerancia: number;
  limiteFalta: number;
  turno: TurnoVigenteRow;
  fechaAsistencia: string;
  guard: string | null;
  mejorEntrada: { marcacionId: number; punchTime: Date; dist: number } | null;
  mejorSalida: { marcacionId: number; punchTime: Date; dist: number } | null;
};

export function targetFechas(
  turno: TurnoVigenteRow,
  fecha: string,
): { entradaIso: string; salidaIso: string } {
  if (turno.esEntradaMatch) {
    const entradaIso = fecha;
    const salidaIso =
      turno.extendido && turno.salidaDiaId
        ? nextWeekdayIso(entradaIso, turno.salidaDiaId)
        : entradaIso;
    return { entradaIso, salidaIso };
  }
  // salida-match (turno extendido): la entrada fue el dia anterior de diaIdEntrada
  const entradaIso = prevWeekdayIso(fecha, turno.diaIdEntrada);
  const salidaIso = fecha;
  return { entradaIso, salidaIso };
}

const procesarMarcaciones = async (
  data: ProcesarAsistenciaDto,
  userId: number,
): Promise<ProcesarAsistenciaResultado> => {
  try {
    return await runTransaction(async (tx) => {
      const estados = await getEstados(tx);
      const pendientes = await getMarcacionesPendientes(
        tx,
        data.usuarioId,
        data.fecha,
      );

      const resultado: ProcesarAsistenciaResultado = {
        procesadas: pendientes.length,
        creadas: 0,
        actualizadas: 0,
        ignoradas: 0,
        errores: [],
        detalle: [],
      };

      const grupos = new Map<string, GrupoTurno>();

      for (const marcacion of pendientes) {
        // 1) Usuario por DNI
        const usuario = await getUsuarioByDni(tx, marcacion.empCode);
        if (!usuario) {
          resultado.errores.push({
            marcacionId: marcacion.marcacionId,
            motivo: 'Usuario no encontrado por DNI',
          });
          continue;
        }

        // 2) Fecha / hora de la marca
        const fecha = isoDate(marcacion.punchTime);
        const hora = timeOf(marcacion.punchTime);

        // 3) Turno vigente mas cercano
        const turno = await getTurnoVigente(tx, usuario.usuarioId, fecha, hora);
        if (!turno) {
          resultado.ignoradas++;
          continue;
        }

        // 4) Fecha de asistencia y targets entrada/salida
        const { entradaIso, salidaIso } = targetFechas(turno, fecha);
        const entradaTarget = atDateTime(entradaIso, turno.horaInicio);
        const salidaTarget = atDateTime(salidaIso, turno.horaFin);
        const distEntrada = Math.abs(
          diffMinutes(marcacion.punchTime, entradaTarget),
        );
        const distSalida = Math.abs(
          diffMinutes(marcacion.punchTime, salidaTarget),
        );

        // 5) Agrupar por (usuario, fechaAsistencia, turno)
        const key = `${usuario.usuarioId}|${entradaIso}|${turno.turnoId}`;
        let grupo = grupos.get(key);
        if (!grupo) {
          const control = await getControlAplicable(
            tx,
            usuario.usuarioId,
            turno.areaId,
            turno.unidadId,
          );
          const guard = await getGuardActivo(tx, usuario.usuarioId, entradaIso);
          grupo = {
            usuarioId: usuario.usuarioId,
            areaId: turno.areaId,
            unidadId: turno.unidadId,
            controlId: control?.controlId ?? null,
            tolerancia: control?.tolerancia ?? 0,
            limiteFalta: control?.limiteFalta ?? 0,
            turno,
            fechaAsistencia: entradaIso,
            guard: guard?.tipoGuard ?? null,
            mejorEntrada: null,
            mejorSalida: null,
          };
          grupos.set(key, grupo);
        }

        // 6) Elegir la marca mas cercana a cada hora
        if (distEntrada <= distSalida) {
          if (!grupo.mejorEntrada || distEntrada < grupo.mejorEntrada.dist) {
            grupo.mejorEntrada = {
              marcacionId: marcacion.marcacionId,
              punchTime: marcacion.punchTime,
              dist: distEntrada,
            };
          }
        } else {
          if (!grupo.mejorSalida || distSalida < grupo.mejorSalida.dist) {
            grupo.mejorSalida = {
              marcacionId: marcacion.marcacionId,
              punchTime: marcacion.punchTime,
              dist: distSalida,
            };
          }
        }
      }

      // 7) Materializar cada grupo
      for (const grupo of grupos.values()) {
        const { turno } = grupo;
        const { entradaIso, salidaIso } = targetFechas(
          turno,
          grupo.fechaAsistencia,
        );
        const entradaTarget = atDateTime(entradaIso, turno.horaInicio);
        const salidaTarget = atDateTime(salidaIso, turno.horaFin);

        const estadoEntradaId = grupo.mejorEntrada
          ? classificarEntrada(
              estados,
              grupo.mejorEntrada.punchTime,
              entradaTarget,
              grupo.tolerancia,
              grupo.limiteFalta,
            )
          : null;
        const estadoSalidaId = grupo.mejorSalida
          ? classificarSalida(
              estados,
              grupo.mejorSalida.punchTime,
              salidaTarget,
            )
          : null;

        let asistenciaId = await getAsistenciaByTurno(
          tx,
          grupo.usuarioId,
          grupo.fechaAsistencia,
          turno.turnoId,
        );

        // Guard gana: ambos estados apuntan al guard, resultado = guard
        if (grupo.guard) {
          const guardId = estados.get(grupo.guard);
          if (!asistenciaId && guardId) {
            const guardOutput = await executeCreate(
              tx,
              'usp_CreateAsistenciaGuard',
              (req) => {
                req.input('UsuarioId', sql.Int, grupo.usuarioId);
                req.input(
                  'Fecha',
                  sql.Date,
                  new Date(`${grupo.fechaAsistencia}T00:00:00`),
                );
                req.input('TurnoId', sql.Int, turno.turnoId);
                req.input('GuardNombre', sql.VarChar(50), grupo.guard!);
                req.input(
                  'turnoEntrada',
                  sql.Time,
                  normalizeSqlTime(turno.horaInicio),
                );
                req.input(
                  'turnoSalida',
                  sql.Time,
                  normalizeSqlTime(turno.horaFin),
                );
                req.input('USER', sql.Int, userId);
                req.output('Id', sql.Int);
              },
            );
            asistenciaId = guardOutput.Id ?? null;
            resultado.creadas++;
          } else if (asistenciaId) {
            resultado.actualizadas++;
          }
          if (asistenciaId) {
            await updateGuardHorasRaw(
              tx,
              asistenciaId,
              grupo.mejorEntrada?.punchTime ?? null,
              grupo.mejorSalida?.punchTime ?? null,
              userId,
            );
            if (grupo.mejorEntrada) {
              await executeCreate(
                tx,
                'usp_CreateAsistenciaMarcacion',
                (req) => {
                  req.input('AsistenciaId', sql.Int, asistenciaId!);
                  req.input(
                    'MarcacionId',
                    sql.Int,
                    grupo.mejorEntrada!.marcacionId,
                  );
                  req.input('BiometricoId', sql.Int, null);
                  req.input('TipoMarcacion', sql.VarChar(50), 'entrada');
                  req.input('USER', sql.Int, userId);
                  req.output('Id', sql.Int);
                },
              );
            }
            if (grupo.mejorSalida) {
              await executeCreate(
                tx,
                'usp_CreateAsistenciaMarcacion',
                (req) => {
                  req.input('AsistenciaId', sql.Int, asistenciaId!);
                  req.input(
                    'MarcacionId',
                    sql.Int,
                    grupo.mejorSalida!.marcacionId,
                  );
                  req.input('BiometricoId', sql.Int, null);
                  req.input('TipoMarcacion', sql.VarChar(50), 'salida');
                  req.input('USER', sql.Int, userId);
                  req.output('Id', sql.Int);
                },
              );
            }
            resultado.detalle.push({
              marcacionId:
                grupo.mejorEntrada?.marcacionId ??
                grupo.mejorSalida?.marcacionId ??
                0,
              asistenciaId,
              usuarioId: grupo.usuarioId,
              fecha: grupo.fechaAsistencia,
              tipoMarcacion: grupo.mejorSalida ? 'salida' : 'entrada',
              estadoEntrada: grupo.guard,
              estadoSalida: grupo.guard,
              resultado: grupo.guard,
            });
          }
          continue;
        }

        // Caso normal (sin guard)
        const entradaIdFinal =
          estadoEntradaId ??
          (grupo.mejorSalida
            ? (estados.get('SinMarcacionEntrada') ?? null)
            : null);
        const salidaIdFinal =
          estadoSalidaId ??
          (grupo.mejorEntrada
            ? (estados.get('SinMarcacionSalida') ?? null)
            : null);

        const resultadoStr = combinarResultado(
          nombreEstado(estados, entradaIdFinal),
          nombreEstado(estados, salidaIdFinal),
        );

        if (asistenciaId) {
          // Asistencia existente: actualizar entrada y salida
          if (grupo.mejorEntrada) {
            await updateEntradaRaw(
              tx,
              asistenciaId,
              grupo.mejorEntrada.punchTime,
              entradaIdFinal,
              resultadoStr,
              userId,
            );
          }
          if (grupo.mejorSalida) {
            await executeCreate(tx, 'usp_UpdateAsistenciaSalida', (req) => {
              req.input('AsistenciaId', sql.Int, asistenciaId!);
              req.input(
                'HoraSalida',
                sql.DateTime2,
                grupo.mejorSalida!.punchTime,
              );
              req.input('EstadoSalidaId', sql.Int, salidaIdFinal);
              req.input('ResultadoAsistencia', sql.VarChar(50), null);
              req.input('USER', sql.Int, userId);
            });
          }
          resultado.actualizadas++;
        } else {
          const createOutput = await executeCreate(
            tx,
            'usp_CreateAsistencia',
            (req) => {
              req.input('UsuarioId', sql.Int, grupo.usuarioId);
              req.input(
                'Fecha',
                sql.Date,
                new Date(`${grupo.fechaAsistencia}T00:00:00`),
              );
              req.input('TurnoId', sql.Int, turno.turnoId);
              req.input(
                'HoraEntrada',
                sql.DateTime2,
                grupo.mejorEntrada?.punchTime ?? null,
              );
              req.input('EstadoEntradaId', sql.Int, entradaIdFinal);
              req.input('EstadoSalidaId', sql.Int, salidaIdFinal);
              req.input('ResultadoAsistencia', sql.VarChar(50), resultadoStr);
              req.input('ControlId', sql.Int, grupo.controlId);
              req.input(
                'vigenciaInicio',
                sql.Date,
                turno.fechaInicio
                  ? new Date(`${dateValue(turno.fechaInicio)}T00:00:00`)
                  : null,
              );
              req.input(
                'vigenciaFin',
                sql.Date,
                turno.fechaFin
                  ? new Date(`${dateValue(turno.fechaFin)}T00:00:00`)
                  : null,
              );
              req.input(
                'turnoEntrada',
                sql.Time,
                normalizeSqlTime(turno.horaInicio),
              );
              req.input(
                'turnoSalida',
                sql.Time,
                normalizeSqlTime(turno.horaFin),
              );
              req.input('USER', sql.Int, userId);
              req.output('Id', sql.Int);
            },
          );
          asistenciaId = createOutput.Id ?? null;
          resultado.creadas++;

          // La salida se actualiza despues de insertar (HoraSalida = NULL al insert)
          if (grupo.mejorSalida && asistenciaId) {
            await executeCreate(tx, 'usp_UpdateAsistenciaSalida', (req) => {
              req.input('AsistenciaId', sql.Int, asistenciaId!);
              req.input(
                'HoraSalida',
                sql.DateTime2,
                grupo.mejorSalida!.punchTime,
              );
              req.input('EstadoSalidaId', sql.Int, salidaIdFinal);
              req.input('ResultadoAsistencia', sql.VarChar(50), resultadoStr);
              req.input('USER', sql.Int, userId);
            });
          }
        }

        // Enlazar marcaciones
        if (asistenciaId) {
          if (grupo.mejorEntrada) {
            await executeCreate(tx, 'usp_CreateAsistenciaMarcacion', (req) => {
              req.input('AsistenciaId', sql.Int, asistenciaId);
              req.input(
                'MarcacionId',
                sql.Int,
                grupo.mejorEntrada!.marcacionId,
              );
              req.input('BiometricoId', sql.Int, null);
              req.input('TipoMarcacion', sql.VarChar(50), 'entrada');
              req.input('USER', sql.Int, userId);
              req.output('Id', sql.Int);
            });
          }
          if (grupo.mejorSalida) {
            await executeCreate(tx, 'usp_CreateAsistenciaMarcacion', (req) => {
              req.input('AsistenciaId', sql.Int, asistenciaId);
              req.input('MarcacionId', sql.Int, grupo.mejorSalida!.marcacionId);
              req.input('BiometricoId', sql.Int, null);
              req.input('TipoMarcacion', sql.VarChar(50), 'salida');
              req.input('USER', sql.Int, userId);
              req.output('Id', sql.Int);
            });
          }
        }

        resultado.detalle.push({
          marcacionId:
            grupo.mejorEntrada?.marcacionId ??
            grupo.mejorSalida?.marcacionId ??
            0,
          asistenciaId,
          usuarioId: grupo.usuarioId,
          fecha: grupo.fechaAsistencia,
          tipoMarcacion:
            grupo.mejorSalida && !grupo.mejorEntrada ? 'salida' : 'entrada',
          estadoEntrada: nombreEstado(estados, entradaIdFinal),
          estadoSalida: nombreEstado(estados, salidaIdFinal),
          resultado: resultadoStr,
        });
      }

      return resultado;
    });
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

// ---------------------------------------------------------------------------
// reprocesar-asistencias
// ---------------------------------------------------------------------------

async function getAsistenciasReprocesar(
  tx: sql.Transaction,
  usuarioId?: number,
  fecha?: string,
): Promise<{
  asistencias: ReprocesarAsistenciaRow[];
  faltas: ReprocesarFaltaRow[];
}> {
  const request = new sql.Request(tx);
  request.input('UsuarioId', sql.Int, usuarioId ?? null);
  request.input(
    'Fecha',
    sql.Date,
    fecha ? new Date(`${fecha}T00:00:00`) : null,
  );
  const result = await request.execute('usp_GetAsistenciasReprocesar');
  const recordsets = result.recordsets as unknown as Array<Array<unknown>>;
  return {
    asistencias: (recordsets[0] ?? []) as ReprocesarAsistenciaRow[],
    faltas: (recordsets[1] ?? []) as ReprocesarFaltaRow[],
  };
}

const reprocesarAsistencias = async (
  data: ProcesarAsistenciaDto,
  userId: number,
): Promise<ProcesarAsistenciaResultado> => {
  try {
    return await runTransaction(async (tx) => {
      const estados = await getEstados(tx);
      const { asistencias, faltas } = await getAsistenciasReprocesar(
        tx,
        data.usuarioId,
        data.fecha,
      );

      const resultado: ProcesarAsistenciaResultado = {
        procesadas: asistencias.length + faltas.length,
        creadas: 0,
        actualizadas: 0,
        ignoradas: 0,
        errores: [],
        detalle: [],
      };

      // Agrupar por asistencia
      const porAsistencia = new Map<
        number,
        {
          row: ReprocesarAsistenciaRow;
          marcas: { tipo: string; punchTime: Date }[];
        }
      >();
      for (const row of asistencias) {
        let grupo = porAsistencia.get(row.asistenciaId);
        if (!grupo) {
          grupo = { row, marcas: [] };
          porAsistencia.set(row.asistenciaId, grupo);
        }
        if (row.punchTime && row.tipoMarcacion) {
          grupo.marcas.push({
            tipo: row.tipoMarcacion,
            punchTime: row.punchTime,
          });
        }
      }

      const NOMBRES_GUARD = new Set([
        'Vacaciones',
        'Licencia',
        'Permiso',
        'Justificado',
        'VigenciaVencida',
      ]);

      for (const { row, marcas } of porAsistencia.values()) {
        const nombreResultado = nombreEstado(estados, row.estadoEntradaId);
        if (nombreResultado && NOMBRES_GUARD.has(nombreResultado)) {
          resultado.ignoradas++;
          continue;
        }
        if (!row.turnoEntrada || !row.turnoSalida || !row.turnoId) {
          resultado.ignoradas++;
          continue;
        }

        const entradaTarget = atDateTime(
          dateValue(row.fecha),
          row.turnoEntrada,
        );
        const salidaTarget = atDateTime(dateValue(row.fecha), row.turnoSalida);

        let mejorEntrada: Date | null = null;
        let mejorSalida: Date | null = null;
        let distEntrada = Infinity;
        let distSalida = Infinity;
        for (const marca of marcas) {
          if (marca.tipo === 'entrada') {
            const d = Math.abs(diffMinutes(marca.punchTime, entradaTarget));
            if (d < distEntrada) {
              distEntrada = d;
              mejorEntrada = marca.punchTime;
            }
          } else if (marca.tipo === 'salida') {
            const d = Math.abs(diffMinutes(marca.punchTime, salidaTarget));
            if (d < distSalida) {
              distSalida = d;
              mejorSalida = marca.punchTime;
            }
          }
        }

        const tolerancia = 0;
        const limiteFalta = 0;
        const entradaId = mejorEntrada
          ? classificarEntrada(
              estados,
              mejorEntrada,
              entradaTarget,
              tolerancia,
              limiteFalta,
            )
          : null;
        const salidaId = mejorSalida
          ? classificarSalida(estados, mejorSalida, salidaTarget)
          : null;

        const entradaIdFinal =
          entradaId ??
          (mejorSalida ? (estados.get('SinMarcacionEntrada') ?? null) : null);
        const salidaIdFinal =
          salidaId ??
          (mejorEntrada ? (estados.get('SinMarcacionSalida') ?? null) : null);
        const resultadoStr = combinarResultado(
          nombreEstado(estados, entradaIdFinal),
          nombreEstado(estados, salidaIdFinal),
        );

        await updateEntradaRaw(
          tx,
          row.asistenciaId,
          mejorEntrada,
          entradaIdFinal,
          resultadoStr,
          userId,
        );
        if (mejorSalida) {
          await executeCreate(tx, 'usp_UpdateAsistenciaSalida', (req) => {
            req.input('AsistenciaId', sql.Int, row.asistenciaId);
            req.input('HoraSalida', sql.DateTime2, mejorSalida);
            req.input('EstadoSalidaId', sql.Int, salidaIdFinal);
            req.input('ResultadoAsistencia', sql.VarChar(50), resultadoStr);
            req.input('USER', sql.Int, userId);
          });
        }
        resultado.actualizadas++;
        resultado.detalle.push({
          marcacionId: 0,
          asistenciaId: row.asistenciaId,
          usuarioId: row.usuarioId,
          fecha: dateValue(row.fecha),
          tipoMarcacion: 'entrada',
          estadoEntrada: nombreEstado(estados, entradaIdFinal),
          estadoSalida: nombreEstado(estados, salidaIdFinal),
          resultado: resultadoStr,
        });
      }

      // Crear Falta (o guard) para turnos vigentes sin asistencia ya finalizados
      for (const falta of faltas) {
        const fechaFalta = dateValue(falta.fecha);
        const guard = await getGuardActivo(tx, falta.usuarioId, fechaFalta);
        const nombreGuard = guard?.tipoGuard ?? 'Falta';
        const output = await executeCreate(
          tx,
          'usp_CreateAsistenciaGuard',
          (req) => {
            req.input('UsuarioId', sql.Int, falta.usuarioId);
            req.input('Fecha', sql.Date, new Date(`${fechaFalta}T00:00:00`));
            req.input('TurnoId', sql.Int, falta.turnoId);
            req.input('GuardNombre', sql.VarChar(50), nombreGuard);
            req.input(
              'turnoEntrada',
              sql.Time,
              normalizeSqlTime(falta.horaInicio),
            );
            req.input('turnoSalida', sql.Time, normalizeSqlTime(falta.horaFin));
            req.input('USER', sql.Int, userId);
            req.output('Id', sql.Int);
          },
        );
        resultado.creadas++;
        resultado.detalle.push({
          marcacionId: 0,
          asistenciaId: output.Id ?? null,
          usuarioId: falta.usuarioId,
          fecha: fechaFalta,
          tipoMarcacion: 'entrada',
          estadoEntrada: nombreGuard,
          estadoSalida: nombreGuard,
          resultado: nombreGuard,
        });
      }

      return resultado;
    });
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

export default {
  procesarMarcaciones,
  reprocesarAsistencias,
};
