import UsuarioRepo from './repository.js';
import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import { Usuario } from './dto/usuario.dto.js';
import { SyncUsuario } from './dto/sync-usuario.dto.js';
import { ActualizarActivoDto } from './dto/actualizar-activo.dto.js';
import { MigrarSyncUsuarioDto } from './dto/migrar-syncUsuario.dto.js';

const _getAllMigrados = (
  activo?: boolean,
  tipo?: string,
  busqueda?: string,
): Promise<Usuario[]> => {
  return UsuarioRepo.getAllMigrados(activo, tipo, busqueda);
};

const _getAllSync = (): Promise<SyncUsuario[]> => {
  return UsuarioRepo.getAllSync();
};

const _updateActivo = (
  id: number,
  data: ActualizarActivoDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return UsuarioRepo.updateActivo(id, data, userId);
};

const _migrar = (
  data: MigrarSyncUsuarioDto,
): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return UsuarioRepo.migrar(data.syncUsuarioId, userId);
};

export const UsuarioService = {
  getAllMigrados: _getAllMigrados,
  getAllSync: _getAllSync,
  updateActivo: _updateActivo,
  migrar: _migrar,
};
