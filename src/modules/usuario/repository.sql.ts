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
  ActualizarUsuarioDto,
  AsignarUsuarioDto,
  Usuario,
} from './dto/usuario.dto.js';

const getAll = async (
  rolId?: number,
  unidadId?: number,
  busqueda?: string,
): Promise<Usuario[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('rolId', sql.Int, rolId ?? null);
    request.input('unidadId', sql.Int, unidadId ?? null);
    request.input('busqueda', sql.VarChar(255), busqueda ?? null);

    const result = await request.execute<Usuario>('usp_ListarRolUsuarios');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const create = async (
  data: AsignarUsuarioDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('usuarioId', sql.Int, data.usuarioId);
    request.input('rolId', sql.Int, data.rolId);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_CrearRolUsuario');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const update = async (
  id: number,
  data: ActualizarUsuarioDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('rolId', sql.Int, data.rolId);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_ActualizarRolUsuario');
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

    const result = await request.execute('usp_EliminarRolUsuario');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

export default {
  getAll,
  create,
  update,
  remove,
};
