import UsuarioRepo from './repository.js';
import { authService } from '@src/common/auth.service.js';
import { OperationResult } from '@src/common/types/operation-result.js';
import { Usuario } from './dto/usuario.dto.js';
import { SyncUsuario } from './dto/sync-usuario.dto.js';
import { ActualizarUsuarioDto } from './dto/actualizar-usuario.dto.js';

const _getAllMigrados = (
  activo?: boolean,
  tipo?: string,
  busqueda?: string,
  areaId?: number,
  unidadId?: number,
): Promise<Usuario[]> => {
  return UsuarioRepo.getAllMigrados(activo, tipo, busqueda, areaId, unidadId);
};

const _getById = (id: number): Promise<Usuario | null> => {
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

export const UsuarioService = {
  getAllMigrados: _getAllMigrados,
  getById: _getById,
  getAllSync: _getAllSync,
  update: _update,
};
