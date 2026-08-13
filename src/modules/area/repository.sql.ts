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
import { Area } from './dto/area.dto.js';
import { UsuarioArea } from './dto/usuario-area.dto.js';
import { CrearAreaDto } from './dto/crear-area.dto.js';
import { ActualizarAreaDto } from './dto/actualizar-area.dto.js';

const getAll = async (
  unidadId?: number,
  busqueda?: string,
  tipo?: string,
): Promise<Area[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('unidadId', sql.Int, unidadId ?? null);
    request.input('busqueda', sql.VarChar(255), busqueda ?? null);
    request.input('tipo', sql.VarChar(50), tipo ?? null);

    const result = await request.execute<Area>('usp_GetAreas');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const create = async (
  data: CrearAreaDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('Nombre', sql.VarChar(200), data.nombre);
    request.input('Descripcion', sql.VarChar(255), data.descripcion ?? null);
    request.input('UnidadId', sql.Int, data.unidadId);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_CreateArea');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const update = async (
  id: number,
  data: ActualizarAreaDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('Nombre', sql.VarChar(200), data.nombre ?? null);
    request.input('Descripcion', sql.VarChar(255), data.descripcion ?? null);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UpdateArea');
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

    const result = await request.execute('usp_DeleteArea');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const getUsuarios = async (areaId: number): Promise<UsuarioArea[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('AreaId', sql.Int, areaId);

    const result = await request.execute<UsuarioArea>('usp_GetAreaUsuarios');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const asignarUsuarios = async (
  areaId: number,
  syncUsuarioIds: number[],
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('AreaId', sql.Int, areaId);

    const tvp = new sql.Table('IntListTableType');
    tvp.columns.add('Value', sql.Int);
    for (const id of syncUsuarioIds) {
      tvp.rows.add(id);
    }
    request.input('SyncUsuarioIds', sql.TVP, tvp);

    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UnitWorkAsignarUsuariosArea');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

export default {
  getAll,
  create,
  update,
  remove,
  getUsuarios,
  asignarUsuarios,
};
