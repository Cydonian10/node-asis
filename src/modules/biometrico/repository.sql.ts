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
import { Biometrico } from './dto/biometrico.dto.js';
import { CrearBiometricoDto } from './dto/crear-biometrico.dto.js';
import { ActualizarBiometricoDto } from './dto/actualizar-biometrico.dto.js';

const getAll = async (): Promise<Biometrico[]> => {
  try {
    const pool = await connectToDb();
    const result = await pool.request().execute<Biometrico>('usp_GetBiometricos');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getById = async (id: number): Promise<Biometrico | null> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ID', sql.Int, id);
    const result = await request.execute<Biometrico>('usp_GetBiometricoById');
    return getFirstRecordOrNull(result.recordset);
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const create = async (
  data: CrearBiometricoDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('TerminalId', sql.Int, data.terminalId);
    request.input('MarcaBiometricoId', sql.Int, data.marcaBiometricoId);
    request.input('Nombre', sql.VarChar(40), data.nombre);
    request.input('Ip', sql.VarChar(20), data.ip);
    request.input('Serie', sql.VarChar(20), data.serie);
    request.input('Ubicacion', sql.VarChar(50), data.ubicacion);
    request.input('Tarjeta', sql.Bit, data.tarjeta);
    request.input('Huella', sql.Bit, data.huella);
    request.input('Rostro', sql.Bit, data.rostro);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_CreateBiometrico');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const update = async (
  id: number,
  data: ActualizarBiometricoDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ID', sql.Int, id);
    request.input('TerminalId', sql.Int, data.terminalId);
    request.input('MarcaBiometricoId', sql.Int, data.marcaBiometricoId);
    request.input('Nombre', sql.VarChar(40), data.nombre);
    request.input('Ip', sql.VarChar(20), data.ip);
    request.input('Serie', sql.VarChar(20), data.serie);
    request.input('Ubicacion', sql.VarChar(50), data.ubicacion);
    request.input('Tarjeta', sql.Bit, data.tarjeta);
    request.input('Huella', sql.Bit, data.huella);
    request.input('Rostro', sql.Bit, data.rostro);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_UpdateBiometrico');
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
    const result = await request.execute('usp_DeleteBiometrico');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

export default { getAll, getById, create, update, remove };
