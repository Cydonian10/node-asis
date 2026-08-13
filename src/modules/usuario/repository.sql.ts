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
import { Usuario } from './dto/usuario.dto.js';
import { SyncUsuario } from './dto/sync-usuario.dto.js';
import { ActualizarUsuarioDto } from './dto/actualizar-usuario.dto.js';
import { CrearSyncUsuarioDto } from './dto/crear-sync-usuario.dto.js';

const getAllMigrados = async (
  activo?: boolean,
  tipo?: string,
  busqueda?: string,
  areaId?: number,
  unidadId?: number,
): Promise<Usuario[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('activo', sql.Bit, activo ?? null);
    request.input('tipo', sql.VarChar(10), tipo ?? null);
    request.input('busqueda', sql.VarChar(255), busqueda ?? null);
    request.input('areaId', sql.Int, areaId ?? null);
    request.input('unidadId', sql.Int, unidadId ?? null);

    const result = await request.execute<Usuario>('usp_GetUsuarios');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getById = async (id: number): Promise<Usuario[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('usuarioId', sql.Int, id);

    const result = await request.execute<Usuario>('usp_GetUsuario');
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

const update = async (
  id: number,
  data: ActualizarUsuarioDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('Activo', sql.Bit, data.activo ?? null);
    request.input('UsuarioAreaId', sql.Int, data.usuarioAreaId ?? null);
    request.input('AreaId', sql.Int, data.areaId ?? null);
    request.input('EsSupervisor', sql.Bit, data.esSupervisor ?? null);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UpdateUsuario');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.update(error as string);
  }
};

const createSyncUsuario = async (
  data: CrearSyncUsuarioDto,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('SyncUsuarioId', sql.Int, data.syncUsuarioId ?? null);
    request.input('Usuario', sql.VarChar(200), data.usuario);
    request.input('Nombres', sql.VarChar(200), data.nombres ?? null);
    request.input('Apellidos', sql.VarChar(200), data.apellidos ?? null);
    request.input('Tipo', sql.VarChar(50), data.tipo ?? null);
    request.input('Dni', sql.VarChar(20), data.dni ?? null);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_CreateSyncUsuario');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

export default {
  getAllMigrados,
  getById,
  getAllSync,
  update,
  createSyncUsuario,
};
