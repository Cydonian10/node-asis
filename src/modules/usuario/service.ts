import UsuarioRepo from './repository.js';
import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import { Usuario } from './dto/usuario.dto.js';
import { SyncUsuario } from './dto/sync-usuario.dto.js';
import { ActualizarUsuarioDto } from './dto/actualizar-usuario.dto.js';
import { CrearSyncUsuarioDto } from './dto/crear-sync-usuario.dto.js';
import { UsuarioHorarioAsignacion } from './dto/usuario-horario-asignacion.dto.js';

const _getAllMigrados = (
  activo?: boolean,
  tipo?: string,
  busqueda?: string,
  areaId?: number,
  unidadId?: number,
): Promise<Usuario[]> => {
  return UsuarioRepo.getAllMigrados(activo, tipo, busqueda, areaId, unidadId);
};

const _getById = (id: number): Promise<Usuario[]> => {
  return UsuarioRepo.getById(id);
};

const _getAllSync = (): Promise<SyncUsuario[]> => {
  return UsuarioRepo.getAllSync();
};

const _update = (
  id: number,
  data: ActualizarUsuarioDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return UsuarioRepo.update(id, data, userId);
};

const _createSyncUsuario = (
  data: CrearSyncUsuarioDto,
): Promise<OperationResultCreate> => {
  return UsuarioRepo.createSyncUsuario(data);
};

const _getHorarios = (
  usuarioId: number,
): Promise<UsuarioHorarioAsignacion[]> => {
  return UsuarioRepo.getHorarios(usuarioId);
};

export const UsuarioService = {
  getAllMigrados: _getAllMigrados,
  getById: _getById,
  getAllSync: _getAllSync,
  update: _update,
  createSyncUsuario: _createSyncUsuario,
  getHorarios: _getHorarios,
};
