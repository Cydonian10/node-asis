import sql from 'mssql';
import { connectToDb } from '@src/config/db-sqlserver.js';
import {
  ErrorUtil,
  handleOperationResult,
  handleOperationResultCreate,
} from '@src/util/handleOperationResult.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import { Horario } from './dto/horario.dto.js';
import { HorarioDetalle } from './dto/horario-detalle.dto.js';
import { UsuarioHorario } from './dto/usuario-horario.dto.js';
import { CrearHorarioDto } from './dto/crear-horario.dto.js';
import { ActualizarHorarioDto } from './dto/actualizar-horario.dto.js';
import { CrearDiaDto } from './dto/crear-dia.dto.js';
import { ActualizarDiaDto } from './dto/actualizar-dia.dto.js';
import { CrearTurnoDto } from './dto/crear-turno.dto.js';
import { ActualizarTurnoDto } from './dto/actualizar-turno.dto.js';
import { CrearVigenciaDto } from './dto/crear-vigencia.dto.js';
import { ActualizarVigenciaDto } from './dto/actualizar-vigencia.dto.js';

export function normalizeSqlTime(
  value: string | null | undefined,
): Date | null {
  if (value === null || value === undefined) return null;

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

  return new Date(1970, 0, 1, hours, minutes, seconds, 0);
}

const getAll = async (
  areaId?: number,
  busqueda?: string,
): Promise<Horario[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('areaId', sql.Int, areaId ?? null);
    request.input('busqueda', sql.VarChar(255), busqueda ?? null);

    const result = await request.execute<Horario>('usp_GetHorarios');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

type DetalleRow = {
  horarioDiaId: number;
  diaId: number;
  diaNombre: string;
  orden: number;
  turnoId: number | null;
  horaInicio: string | null;
  horaFin: string | null;
  extendido: boolean | null;
  vigenciaId: number | null;
  fechaInicio: string | null;
  fechaFin: string | null;
};

type HorarioRow = {
  horarioId: number;
  nombre: string;
  areaId: number;
  areaNombre: string | null;
  unidadId: number;
  extendido: boolean;
  rotativo: boolean;
  regular: boolean;
  horasLaborales: number;
};

const getById = async (id: number): Promise<HorarioDetalle | null> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioId', sql.Int, id);

    const result = await request.execute('usp_GetHorarioDetalle');
    const recordsets = result.recordsets as unknown as Array<Array<unknown>>;
    const horarios = recordsets[0] as unknown as HorarioRow[];
    const filas = recordsets[2] as unknown as DetalleRow[];

    if (horarios.length === 0) return null;

    const h = horarios[0];
    const diasMap = new Map<number, HorarioDetalle['dias'][number]>();

    for (const f of filas) {
      let dia = diasMap.get(f.horarioDiaId);
      if (!dia) {
        dia = {
          horarioDiaId: f.horarioDiaId,
          diaId: f.diaId,
          diaNombre: f.diaNombre,
          orden: f.orden,
          vigencia: f.vigenciaId
            ? {
                vigenciaId: f.vigenciaId,
                fechaInicio: f.fechaInicio,
                fechaFin: f.fechaFin,
              }
            : null,
          turnos: [],
        };
        diasMap.set(f.horarioDiaId, dia);
      }
      if (f.turnoId !== null && f.turnoId !== undefined) {
        dia.turnos.push({
          turnoId: f.turnoId,
          horaInicio: f.horaInicio ?? '',
          horaFin: f.horaFin ?? '',
          extendido: !!f.extendido,
        });
      }
    }

    return {
      horarioId: h.horarioId,
      nombre: h.nombre,
      areaId: h.areaId,
      areaNombre: h.areaNombre,
      unidadId: h.unidadId,
      extendido: !!h.extendido,
      rotativo: !!h.rotativo,
      regular: !!h.regular,
      horasLaborales: h.horasLaborales,
      dias: Array.from(diasMap.values()).sort((a, b) => a.orden - b.orden),
      usuarios: [],
    };
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getUsuarios = async (horarioId: number): Promise<UsuarioHorario[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioId', sql.Int, horarioId);

    const result = await request.execute<UsuarioHorario>(
      'usp_GetHorarioUsuarios',
    );
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

async function runInTransaction<T>(
  fn: (tx: sql.Transaction) => Promise<T>,
): Promise<T> {
  const pool = await connectToDb();
  const tx = new sql.Transaction(pool);
  await tx.begin();
  try {
    const result = await fn(tx);
    await tx.commit();
    return result;
  } catch (error) {
    try {
      await tx.rollback();
    } catch {
      // el rollback puede fallar si la transaccion ya se cerro; no encubrimos el error original
    }
    throw error;
  }
}

type SPOutput = {
  State: number;
  Message: string;
  CodeError: number;
  Id?: number | null;
};

async function executeCreate(
  tx: sql.Transaction,
  name: string,
  fn: (req: sql.Request) => void,
): Promise<{ output: SPOutput }> {
  const req = new sql.Request(tx);
  fn(req);
  req.output('State', sql.Int);
  req.output('Message', sql.VarChar(255));
  req.output('CodeError', sql.Int);
  const result = await req.execute(name);
  const output = result.output as unknown as SPOutput;
  if (output.State !== 1) {
    throw new Error(`SP ${name} falló: ${output.Message}`);
  }
  return { output };
}

function requireId(output: SPOutput, sp: string): number {
  if (output.Id === null || output.Id === undefined) {
    throw new Error(`SP ${sp} no devolvió Id`);
  }
  return output.Id;
}

const create = async (
  data: CrearHorarioDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    return await runInTransaction(async (tx) => {
      const horarioRes = await executeCreate(tx, 'usp_CreateHorario', (req) => {
        req.input('Nombre', sql.VarChar(200), data.nombre);
        req.input('AreaId', sql.Int, data.areaId);
        req.input('Extendido', sql.Bit, data.extendido);
        req.input('Rotativo', sql.Bit, data.rotativo);
        req.input('Regular', sql.Bit, data.regular);
        req.input('HorasLaborales', sql.Int, data.horasLaborales);
        req.input('USER', sql.Int, userId);
        req.output('Id', sql.Int);
      });

      const horarioId = requireId(horarioRes.output, 'usp_CreateHorario');

      for (const dia of data.dias) {
        const diaRes = await executeCreate(
          tx,
          'usp_CreateHorarioDia',
          (req) => {
            req.input('HorarioId', sql.Int, horarioId);
            req.input('DiaId', sql.Int, dia.diaId);
            req.input('Orden', sql.Int, dia.orden ?? 0);
            req.input('USER', sql.Int, userId);
            req.output('Id', sql.Int);
          },
        );
        const horarioDiaId = requireId(diaRes.output, 'usp_CreateHorarioDia');

        if (dia.vigencia) {
          await executeCreate(tx, 'usp_CreateVigencia', (req) => {
            req.input('HorarioDiaId', sql.Int, horarioDiaId);
            req.input(
              'FechaInicio',
              sql.Date,
              new Date(dia.vigencia!.fechaInicio),
            );
            req.input(
              'FechaFin',
              sql.Date,
              dia.vigencia!.fechaFin ? new Date(dia.vigencia!.fechaFin) : null,
            );
            req.input('USER', sql.Int, userId);
            req.output('Id', sql.Int);
          });
        }

        for (const turno of dia.turnos) {
          await executeCreate(tx, 'usp_CreateTurno', (req) => {
            req.input('HorarioDiaId', sql.Int, horarioDiaId);
            req.input(
              'HoraInicio',
              sql.Time,
              normalizeSqlTime(turno.horaInicio),
            );
            req.input('HoraFin', sql.Time, normalizeSqlTime(turno.horaFin));
            req.input('Extendido', sql.Bit, turno.extendido ?? false);
            req.input('USER', sql.Int, userId);
            req.output('Id', sql.Int);
          });
        }
      }

      if (data.usuarioIds && data.usuarioIds.length > 0) {
        const req = new sql.Request(tx);
        req.input('HorarioId', sql.Int, horarioId);
        const tvp = new sql.Table('IntListTableType');
        tvp.columns.add('Value', sql.Int);
        for (const id of data.usuarioIds) {
          tvp.rows.add(id);
        }
        req.input('UsuarioIds', sql.TVP, tvp);
        req.input('USER', sql.Int, userId);
        req.output('State', sql.Int);
        req.output('Message', sql.VarChar(255));
        req.output('CodeError', sql.Int);
        const res = await req.execute('usp_AsignarUsuariosHorario');
        const resOutput = res.output as unknown as SPOutput;
        if (resOutput.State !== 1) {
          throw new Error(
            `SP usp_AsignarUsuariosHorario falló: ${resOutput.Message}`,
          );
        }
      }

      return {
        Id: horarioId,
        State: 1,
        Message: 'Horario creado correctamente',
        CodeError: 0,
      };
    });
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const update = async (
  id: number,
  data: ActualizarHorarioDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('Nombre', sql.VarChar(200), data.nombre ?? null);
    request.input('AreaId', sql.Int, data.areaId ?? null);
    request.input('Extendido', sql.Bit, data.extendido ?? null);
    request.input('Rotativo', sql.Bit, data.rotativo ?? null);
    request.input('Regular', sql.Bit, data.regular ?? null);
    request.input('HorasLaborales', sql.Int, data.horasLaborales ?? null);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UpdateHorario');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.update(error as string);
  }
};

const remove = async (id: number, userId: number): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DeleteHorario');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const createDia = async (
  horarioId: number,
  data: CrearDiaDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    return await runInTransaction(async (tx) => {
      const diaRes = await executeCreate(tx, 'usp_CreateHorarioDia', (req) => {
        req.input('HorarioId', sql.Int, horarioId);
        req.input('DiaId', sql.Int, data.diaId);
        req.input('Orden', sql.Int, data.orden ?? 0);
        req.input('USER', sql.Int, userId);
        req.output('Id', sql.Int);
      });
      const horarioDiaId = requireId(diaRes.output, 'usp_CreateHorarioDia');

      if (data.vigencia) {
        await executeCreate(tx, 'usp_CreateVigencia', (req) => {
          req.input('HorarioDiaId', sql.Int, horarioDiaId);
          req.input(
            'FechaInicio',
            sql.Date,
            new Date(data.vigencia!.fechaInicio),
          );
          req.input(
            'FechaFin',
            sql.Date,
            data.vigencia!.fechaFin ? new Date(data.vigencia!.fechaFin) : null,
          );
          req.input('USER', sql.Int, userId);
          req.output('Id', sql.Int);
        });
      }

      return {
        Id: horarioDiaId,
        State: 1,
        Message: 'Dia agregado al horario correctamente',
        CodeError: 0,
      };
    });
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const updateDia = async (
  id: number,
  data: ActualizarDiaDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('Orden', sql.Int, data.orden);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UpdateHorarioDia');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.update(error as string);
  }
};

const removeDia = async (
  id: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DeleteHorarioDia');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const createTurno = async (
  horarioDiaId: number,
  data: CrearTurnoDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioDiaId', sql.Int, horarioDiaId);
    request.input('HoraInicio', sql.Time, normalizeSqlTime(data.horaInicio));
    request.input('HoraFin', sql.Time, normalizeSqlTime(data.horaFin));
    request.input('Extendido', sql.Bit, data.extendido);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_CreateTurno');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const updateTurno = async (
  id: number,
  data: ActualizarTurnoDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('HoraInicio', sql.Time, normalizeSqlTime(data.horaInicio));
    request.input('HoraFin', sql.Time, normalizeSqlTime(data.horaFin));
    request.input('Extendido', sql.Bit, data.extendido ?? null);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UpdateTurno');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.update(error as string);
  }
};

const removeTurno = async (
  id: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DeleteTurno');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const createVigencia = async (
  horarioDiaId: number,
  data: CrearVigenciaDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioDiaId', sql.Int, horarioDiaId);
    request.input('FechaInicio', sql.Date, new Date(data.fechaInicio));
    request.input(
      'FechaFin',
      sql.Date,
      data.fechaFin ? new Date(data.fechaFin) : null,
    );
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_CreateVigencia');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const updateVigencia = async (
  id: number,
  data: ActualizarVigenciaDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input(
      'FechaInicio',
      sql.Date,
      data.fechaInicio ? new Date(data.fechaInicio) : null,
    );
    request.input(
      'FechaFin',
      sql.Date,
      data.fechaFin ? new Date(data.fechaFin) : null,
    );
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UpdateVigencia');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.update(error as string);
  }
};

const removeVigencia = async (
  id: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DeleteVigencia');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const asignarUsuarios = async (
  horarioId: number,
  usuarioIds: number[],
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioId', sql.Int, horarioId);

    const tvp = new sql.Table('IntListTableType');
    tvp.columns.add('Value', sql.Int);
    for (const id of usuarioIds) {
      tvp.rows.add(id);
    }
    request.input('UsuarioIds', sql.TVP, tvp);

    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_AsignarUsuariosHorario');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const desasignarUsuario = async (
  horarioId: number,
  usuarioId: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioId', sql.Int, horarioId);
    request.input('UsuarioId', sql.Int, usuarioId);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DesasignarUsuarioHorario');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

export default {
  getAll,
  getById,
  getUsuarios,
  create,
  update,
  remove,
  createDia,
  updateDia,
  removeDia,
  createTurno,
  updateTurno,
  removeTurno,
  createVigencia,
  updateVigencia,
  removeVigencia,
  asignarUsuarios,
  desasignarUsuario,
};
