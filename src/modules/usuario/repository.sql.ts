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
import {
  Usuario,
} from './dto/usuario.dto.js';
import { SyncUsuario } from './dto/sync-usuario.dto.js';
import { ActualizarActivoDto } from './dto/actualizar-activo.dto.js';

const getAllMigrados = async (
  activo?: boolean,
  tipo?: string,
  busqueda?: string,
): Promise<Usuario[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('activo', sql.Bit, activo ?? null);
    request.input('tipo', sql.VarChar(10), tipo ?? null);
    request.input('busqueda', sql.VarChar(255), busqueda ?? null);

    const result = await request.execute<Usuario>('usp_GetUsuarios');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getAllSync = async (): Promise<SyncUsuario[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    const result = await request.execute<SyncUsuario>('usp_GetSyncUsuarios');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const updateActivo = async (
  id: number,
  data: ActualizarActivoDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('Activo', sql.Bit, data.activo);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UpdateUsuarioActivo');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.update(error as string);
  }
};

const migrar = async (
  syncUsuarioId: number | undefined,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('SyncUsuarioId', sql.Int, syncUsuarioId ?? null);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UnitWorkMigrarSyncUsuario');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

export default {
  getAllMigrados,
  getAllSync,
  updateActivo,
  migrar,
};
