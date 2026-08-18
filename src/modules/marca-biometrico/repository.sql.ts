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
import { MarcaBiometrico } from './dto/marca-biometrico.dto.js';
import { CrearMarcaBiometricoDto } from './dto/crear-marca-biometrico.dto.js';
import { ActualizarMarcaBiometricoDto } from './dto/actualizar-marca-biometrico.dto.js';

const getAll = async (): Promise<MarcaBiometrico[]> => {
  try {
    const pool = await connectToDb();
    const result = await pool.request().execute<MarcaBiometrico>('usp_GetMarcaBiometricos');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getById = async (id: number): Promise<MarcaBiometrico | null> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ID', sql.Int, id);
    const result = await request.execute<MarcaBiometrico>('usp_GetMarcaBiometricoById');
    return getFirstRecordOrNull(result.recordset);
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const create = async (
  data: CrearMarcaBiometricoDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('Nombre', sql.VarChar(30), data.nombre);
    request.input('TipoDB', sql.VarChar(20), data.tipoDB);
    request.input('Detalle', sql.VarChar(50), data.detalle);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_CreateMarcaBiometrico');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const update = async (
  id: number,
  data: ActualizarMarcaBiometricoDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ID', sql.Int, id);
    request.input('Nombre', sql.VarChar(30), data.nombre);
    request.input('TipoDB', sql.VarChar(20), data.tipoDB);
    request.input('Detalle', sql.VarChar(50), data.detalle);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_UpdateMarcaBiometrico');
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
    const result = await request.execute('usp_DeleteMarcaBiometrico');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

export default { getAll, getById, create, update, remove };
