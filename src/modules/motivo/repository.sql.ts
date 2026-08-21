import sql from 'mssql';
import { connectToDb } from '@src/config/db-sqlserver.js';
import {
  ErrorUtil,
  getFirstRecordOrNull,
  handleOperationResult,
  handleOperationResultCreate,
} from '@src/util/handleOperationResult.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import { Motivo } from './dto/motivo.dto.js';
import { CrearMotivoDto } from './dto/crear-motivo.dto.js';
import { ActualizarMotivoDto } from './dto/actualizar-motivo.dto.js';

const getAll = async (): Promise<Motivo[]> => {
  try {
    const pool = await connectToDb();
    const result = await pool.request().execute<Motivo>('usp_GetMotivos');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getById = async (id: number): Promise<Motivo | null> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ID', sql.Int, id);
    const result = await request.execute<Motivo>('usp_GetMotivoById');
    return getFirstRecordOrNull(result.recordset);
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const create = async (
  data: CrearMotivoDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('Nombre', sql.VarChar(100), data.nombre);
    request.input('Descripcion', sql.VarChar(255), data.descripcion ?? null);
    request.input('DocumentoRequerido', sql.Bit, data.documentoRequerido);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_CreateMotivo');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const update = async (
  id: number,
  data: ActualizarMotivoDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ID', sql.Int, id);
    request.input('Nombre', sql.VarChar(100), data.nombre ?? null);
    request.input('Descripcion', sql.VarChar(255), data.descripcion ?? null);
    request.input(
      'DocumentoRequerido',
      sql.Bit,
      data.documentoRequerido ?? null,
    );
    request.input('ActualizarNombre', sql.Bit, data.nombre !== undefined);
    request.input(
      'ActualizarDescripcion',
      sql.Bit,
      data.descripcion !== undefined,
    );
    request.input(
      'ActualizarDocumentoRequerido',
      sql.Bit,
      data.documentoRequerido !== undefined,
    );
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_UpdateMotivo');
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
    const result = await request.execute('usp_DeleteMotivo');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

export default { getAll, getById, create, update, remove };
