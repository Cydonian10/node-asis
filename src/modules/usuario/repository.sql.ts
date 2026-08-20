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
import { LuxonAdapter } from '@src/common/plugins/luxon.js';
import {
  EstadoAsignacion,
  UsuarioHorarioAsignacion,
} from './dto/usuario-horario-asignacion.dto.js';

export type UsuarioTurnoModificado = {
  turnoModificadoId: number;
  turnoId: number;
  usuarioId: number;
  fecha: string;
  horaInicio: string;
  horaFin: string;
  motivo: string | null;
  horarioNombre: string;
};

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

const getHorarios = async (
  usuarioId: number,
): Promise<UsuarioHorarioAsignacion[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('UsuarioId', sql.Int, usuarioId);

    const result = await request.execute<Record<string, unknown>>(
      'usp_GetUsuarioHorarios',
    );
    const hoy = new Date().toISOString().slice(0, 10);

    return (result.recordset ?? []).map((row) => {
      const culminacion = !!row.culminacion;
      const fechaFin = LuxonAdapter.fromSqlServerDate(
        row.fechaFin as string | Date | null,
      );
      let estado: EstadoAsignacion;
      if (culminacion) {
        estado = 'culminado';
      } else if (fechaFin && fechaFin < hoy) {
        estado = 'vencido';
      } else {
        estado = 'activo';
      }
      return {
        horarioAsignacionId: +(row.horarioAsignacionId as number),
        horarioId: +(row.horarioId as number),
        horarioNombre: String(row.horarioNombre ?? ''),
        areaId: +(row.areaId as number),
        areaNombre: (row.areaNombre as string | null) ?? null,
        fechaInicio: LuxonAdapter.fromSqlServerDate(
          row.fechaInicio as string | Date | null,
        ),
        fechaFin,
        culminacion,
        estado,
      };
    });
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getTurnosModificados = async (
  usuarioId: number,
  filters: { fechaDesde?: string; fechaHasta?: string },
): Promise<UsuarioTurnoModificado[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    request.input('UsuarioId', sql.Int, usuarioId);
    request.input(
      'FechaDesde',
      sql.Date,
      filters.fechaDesde ? new Date(`${filters.fechaDesde}T00:00:00.000Z`) : null,
    );
    request.input(
      'FechaHasta',
      sql.Date,
      filters.fechaHasta ? new Date(`${filters.fechaHasta}T00:00:00.000Z`) : null,
    );
    const result = await request.execute<UsuarioTurnoModificado>(
      'usp_GetUsuarioTurnosModificados',
    );
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string) as UsuarioTurnoModificado[];
  }
};

export default {
  getAllMigrados,
  getById,
  getAllSync,
  update,
  createSyncUsuario,
  getHorarios,
  getTurnosModificados,
};
