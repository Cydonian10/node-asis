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
  Control,
  ControlAsignacionArea,
  ControlAsignacionUnidad,
  ControlAsignacionUsuario,
} from './dto/control.dto.js';
import { CrearControlDto } from './dto/crear-control.dto.js';
import { ActualizarControlDto } from './dto/actualizar-control.dto.js';

type ControlRow = Pick<
  Control,
  'controlId' | 'tolerancia' | 'limiteTardanza' | 'limiteFalta'
>;

type ControlRecordsets = [
  ControlRow[],
  ControlAsignacionArea[],
  ControlAsignacionUnidad[],
  ControlAsignacionUsuario[],
];

function composeControls(recordsets: unknown[][]): Control[] {
  const [controles, areas, unidades, usuarios] =
    recordsets as ControlRecordsets;
  const byId = new Map<number, Control>();

  for (const c of controles ?? []) {
    byId.set(c.controlId, {
      controlId: c.controlId,
      tolerancia: c.tolerancia,
      limiteTardanza: c.limiteTardanza,
      limiteFalta: c.limiteFalta,
      areas: [],
      unidades: [],
      usuarios: [],
    });
  }

  for (const a of areas ?? []) {
    byId.get(a.controlId)?.areas.push(a);
  }
  for (const u of unidades ?? []) {
    byId.get(u.controlId)?.unidades.push(u);
  }
  for (const u of usuarios ?? []) {
    byId.get(u.controlId)?.usuarios.push(u);
  }

  return [...byId.values()];
}

const getAll = async (): Promise<Control[]> => {
  try {
    const pool = await connectToDb();
    const result = await pool.request().execute('usp_GetControles');
    return composeControls(result.recordsets as unknown[][]);
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getById = async (id: number): Promise<Control | null> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ID', sql.Int, id);
    const result = await request.execute('usp_GetControlById');
    const controls = composeControls(result.recordsets as unknown[][]);
    return controls[0] || null;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const create = async (
  data: CrearControlDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('Tolerancia', sql.Int, data.tolerancia);
    request.input('LimiteTardanza', sql.Int, data.limiteTardanza);
    request.input('LimiteFalta', sql.Int, data.limiteFalta);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_CreateControl');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const update = async (
  id: number,
  data: ActualizarControlDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ID', sql.Int, id);
    request.input('Tolerancia', sql.Int, data.tolerancia ?? null);
    request.input('LimiteTardanza', sql.Int, data.limiteTardanza ?? null);
    request.input('LimiteFalta', sql.Int, data.limiteFalta ?? null);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_UpdateControl');
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
    const result = await request.execute('usp_DeleteControl');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const assignArea = async (
  controlId: number,
  areaId: number,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ControlId', sql.Int, controlId);
    request.input('AreaId', sql.Int, areaId);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_AssignControlArea');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const assignUnidad = async (
  controlId: number,
  unidadId: number,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ControlId', sql.Int, controlId);
    request.input('UnidadId', sql.Int, unidadId);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_AssignControlUnidad');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const assignUsuario = async (
  controlId: number,
  usuarioId: number,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ControlId', sql.Int, controlId);
    request.input('UsuarioId', sql.Int, usuarioId);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_AssignControlUsuario');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const unassignArea = async (
  controlId: number,
  areaId: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ControlId', sql.Int, controlId);
    request.input('AreaId', sql.Int, areaId);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_UnassignControlArea');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const unassignUnidad = async (
  controlId: number,
  unidadId: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ControlId', sql.Int, controlId);
    request.input('UnidadId', sql.Int, unidadId);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_UnassignControlUnidad');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const unassignUsuario = async (
  controlId: number,
  usuarioId: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('ControlId', sql.Int, controlId);
    request.input('UsuarioId', sql.Int, usuarioId);
    request.input('USER', sql.Int, userId);
    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);
    const result = await request.execute('usp_UnassignControlUsuario');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

export default {
  getAll,
  getById,
  create,
  update,
  remove,
  assignArea,
  assignUnidad,
  assignUsuario,
  unassignArea,
  unassignUnidad,
  unassignUsuario,
};
