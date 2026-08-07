import sql from 'mssql';
import { connectToDb } from '@src/config/db-sqlserver.js';
import {
  executeCreate,
  requireCreatedId,
  runTransaction,
  SPOutput,
} from '@src/util/sqlServerUtil.js';
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
import { mapHorarioDetalle } from './mapper/horario.mapper.js';

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

const getById = async (id: number): Promise<HorarioDetalle | null> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioId', sql.Int, id);

    const result = await request.execute('usp_GetHorarioDetalle');
    const recordsets = result.recordsets as unknown as Array<Array<unknown>>;
    return mapHorarioDetalle(recordsets);
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

const create = async (
  data: CrearHorarioDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    return await runTransaction(async (tx) => {
      const horarioOutput = await executeCreate(
        tx,
        'usp_CreateHorario',
        (req) => {
          req.input('Nombre', sql.VarChar(200), data.nombre);
          req.input('AreaId', sql.Int, data.areaId);
          req.input('Extendido', sql.Bit, data.extendido);
          req.input('Rotativo', sql.Bit, data.rotativo);
          req.input('Regular', sql.Bit, data.regular);
          req.input('HorasLaborales', sql.Int, data.horasLaborales);
          req.input('USER', sql.Int, userId);
          req.output('Id', sql.Int);
        },
      );

      const horarioId = requireCreatedId(horarioOutput, 'usp_CreateHorario');

      for (const dia of data.dias) {
        const diaOutput = await executeCreate(
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
        const horarioDiaId = requireCreatedId(
          diaOutput,
          'usp_CreateHorarioDia',
        );

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
    return await runTransaction(async (tx) => {
      const diaOutput = await executeCreate(
        tx,
        'usp_CreateHorarioDia',
        (req) => {
          req.input('HorarioId', sql.Int, horarioId);
          req.input('DiaId', sql.Int, data.diaId);
          req.input('Orden', sql.Int, data.orden ?? 0);
          req.input('USER', sql.Int, userId);
          req.output('Id', sql.Int);
        },
      );
      const horarioDiaId = requireCreatedId(diaOutput, 'usp_CreateHorarioDia');

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
