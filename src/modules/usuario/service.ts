import UsuarioRepo from './repository.js';
import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import {
  ActualizarUsuarioDto,
  AsignarUsuarioDto,
  Usuario,
} from './dto/usuario.dto.js';

const _getAll = (
  rolId?: number,
  unidadId?: number,
  busqueda?: string,
): Promise<Usuario[]> => {
  return UsuarioRepo.getAll(rolId, unidadId, busqueda);
};

const _create = (data: AsignarUsuarioDto): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return UsuarioRepo.create(data, userId);
};

const _update = (
  id: number,
  data: ActualizarUsuarioDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return UsuarioRepo.update(id, data, userId);
};

const _remove = (id: number): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return UsuarioRepo.remove(id, userId);
};

export const UsuarioService = {
  getAll: _getAll,
  create: _create,
  update: _update,
  remove: _remove,
};
