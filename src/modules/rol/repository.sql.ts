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
import { RolCatalog } from './dto/rol.dto.js';
import { RolUnidad } from './dto/rol-unidad.dto.js';
import { UsuarioRolUnidad } from './dto/usuario-rol-unidad.dto.js';
import { CrearRolUnidadDto } from './dto/crear-rol-unidad.dto.js';

const getRoles = async (): Promise<RolCatalog[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    const result = await request.execute<RolCatalog>('usp_GetRoles');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const createRolUnidad = async (
  unidadId: number,
  data: CrearRolUnidadDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('RolId', sql.Int, data.rolId);
    request.input('UnidadId', sql.Int, unidadId);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_CreateRolUnidad');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const getRolUnidadByUnidad = async (unidadId: number): Promise<RolUnidad[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('UnidadId', sql.Int, unidadId);

    const result = await request.execute<RolUnidad>('usp_GetRolUnidadByUnidad');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const removeRolUnidad = async (
  rolUnidadId: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, rolUnidadId);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DeleteRolUnidad');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const getUsuarios = async (
  rolUnidadId: number,
): Promise<UsuarioRolUnidad[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('RolUnidadId', sql.Int, rolUnidadId);

    const result = await request.execute<UsuarioRolUnidad>(
      'usp_GetRolUnidadUsuarios',
    );
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const asignarUsuarios = async (
  rolUnidadId: number,
  usuarioIds: number[],
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('RolUnidadId', sql.Int, rolUnidadId);

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

    const result = await request.execute(
      'usp_UnitWorkAsignarUsuariosRolUnidad',
    );
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

export default {
  getRoles,
  createRolUnidad,
  getRolUnidadByUnidad,
  removeRolUnidad,
  getUsuarios,
  asignarUsuarios,
};
