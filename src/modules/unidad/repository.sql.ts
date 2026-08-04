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
import { Unidad } from './dto/unidad.dto.js';
import { SyncUnidad } from './dto/sync-unidad.dto.js';
import { ActualizarUnidadDto } from './dto/actualizar-unidad.dto.js';
import { UsuarioUnidad } from './dto/usuario-unidad.dto.js';
import { CrearAreasBatchItem } from './dto/crear-areas-batch.dto.js';

const getAllMigradas = async (busqueda?: string): Promise<Unidad[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('busqueda', sql.VarChar(255), busqueda ?? null);

    const result = await request.execute<Unidad>('usp_GetUnidades');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getAllSync = async (): Promise<SyncUnidad[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    const result = await request.execute<SyncUnidad>('usp_GetSyncUnidades');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const updateHoras = async (
  id: number,
  data: ActualizarUnidadDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('HorasLaborales', sql.Int, data.horasLaborales ?? null);
    request.input(
      'HorasLaboralesTotales',
      sql.Int,
      data.horasLaboralesTotales ?? null,
    );
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UpdateUnidad');
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

    const result = await request.execute('usp_DeleteUnidad');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const migrar = async (
  syncUnidadId: number | undefined,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('SyncUnidadId', sql.Int, syncUnidadId ?? null);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UnitWorkMigrarSyncUnidad');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const getUsuarios = async (unidadId: number): Promise<UsuarioUnidad[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('UnidadId', sql.Int, unidadId);

    const result = await request.execute<UsuarioUnidad>(
      'usp_GetUnidadUsuarios',
    );
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const asignarUsuarios = async (
  unidadId: number,
  usuarioIds: number[],
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('UnidadId', sql.Int, unidadId);

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

    const result = await request.execute('usp_UnitWorkAsignarUsuariosUnidad');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const crearAreas = async (
  unidadId: number,
  areas: CrearAreasBatchItem[],
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('UnidadId', sql.Int, unidadId);

    const tvp = new sql.Table('AreaBatchTableType');
    tvp.columns.add('Nombre', sql.VarChar(200));
    tvp.columns.add('Descripcion', sql.VarChar(255));
    for (const area of areas) {
      tvp.rows.add(area.nombre, area.descripcion ?? null);
    }
    request.input('Areas', sql.TVP, tvp);

    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UnitWorkCrearAreasUnidad');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

export default {
  getAllMigradas,
  getAllSync,
  updateHoras,
  remove,
  migrar,
  getUsuarios,
  asignarUsuarios,
  crearAreas,
};
