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
import { TurnoModificado } from './dto/turno-modificado.dto.js';
import { CrearTurnoModificadoDto } from './dto/crear-turno-modificado.dto.js';
import { ActualizarTurnoModificadoDto } from './dto/actualizar-turno-modificado.dto.js';
import { TurnoModificadoFilterDto } from './dto/turno-modificado-filter.dto.js';

const toSqlDate = (value: string): Date => new Date(`${value}T00:00:00.000Z`);

const toSqlTime = (value: string): string =>
  value.length === 5 ? `${value}:00` : value;

const getAll = async (
  turnoId: number,
  filters: TurnoModificadoFilterDto,
): Promise<TurnoModificado[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('TurnoId', sql.Int, turnoId);
    request.input(
      'FechaDesde',
      sql.Date,
      filters.fechaDesde ? toSqlDate(filters.fechaDesde) : null,
    );
    request.input(
      'FechaHasta',
      sql.Date,
      filters.fechaHasta ? toSqlDate(filters.fechaHasta) : null,
    );
    request.input('UsuarioId', sql.Int, filters.usuarioId ?? null);
    const result = await request.execute<TurnoModificado>(
      'usp_GetTurnoModificados',
    );
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getById = async (
  turnoId: number,
  turnoModificadoId: number,
): Promise<TurnoModificado | null> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('TurnoId', sql.Int, turnoId);
    request.input('TurnoModificadoId', sql.Int, turnoModificadoId);
    const result = await request.execute<TurnoModificado>(
      'usp_GetTurnoModificadoById',
    );
    return result.recordset[0] ?? null;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const create = async (
  turnoId: number,
  data: CrearTurnoModificadoDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('TurnoId', sql.Int, turnoId);
    request.input('UsuarioId', sql.Int, data.usuarioId);
    request.input('Fecha', sql.Date, toSqlDate(data.fecha));
    request.input('HoraInicio', sql.Time, toSqlTime(data.horaInicio));
    request.input('HoraFin', sql.Time, toSqlTime(data.horaFin));
    request.input('Motivo', sql.VarChar(255), data.motivo ?? null);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_CreateTurnoModificado');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const update = async (
  turnoId: number,
  turnoModificadoId: number,
  data: ActualizarTurnoModificadoDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('TurnoId', sql.Int, turnoId);
    request.input('TurnoModificadoId', sql.Int, turnoModificadoId);
    request.input('Fecha', sql.Date, data.fecha ? toSqlDate(data.fecha) : null);
    request.input(
      'HoraInicio',
      sql.Time,
      data.horaInicio ? toSqlTime(data.horaInicio) : null,
    );
    request.input(
      'HoraFin',
      sql.Time,
      data.horaFin ? toSqlTime(data.horaFin) : null,
    );
    request.input('Motivo', sql.VarChar(255), data.motivo ?? null);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_UpdateTurnoModificado');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.update(error as string);
  }
};

const remove = async (
  turnoId: number,
  turnoModificadoId: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('TurnoId', sql.Int, turnoId);
    request.input('TurnoModificadoId', sql.Int, turnoModificadoId);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_DeleteTurnoModificado');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

export default { getAll, getById, create, update, remove };
