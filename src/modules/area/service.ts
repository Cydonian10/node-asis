import AreaRepo from './repository.js';
import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import { Area } from './dto/area.dto.js';
import { UsuarioArea } from './dto/usuario-area.dto.js';
import { CrearAreaDto } from './dto/crear-area.dto.js';
import { ActualizarAreaDto } from './dto/actualizar-area.dto.js';
import { AsignarUsuariosDto } from './dto/asignar-usuarios.dto.js';

const _getAll = (
  unidadId?: number,
  busqueda?: string,
  tipo?: string,
): Promise<Area[]> => {
  return AreaRepo.getAll(unidadId, busqueda, tipo);
};

const _create = (data: CrearAreaDto): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return AreaRepo.create(data, userId);
};

const _update = (
  id: number,
  data: ActualizarAreaDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return AreaRepo.update(id, data, userId);
};

const _remove = (id: number): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return AreaRepo.remove(id, userId);
};

const _getUsuarios = (areaId: number): Promise<UsuarioArea[]> => {
  return AreaRepo.getUsuarios(areaId);
};

const _asignarUsuarios = (
  areaId: number,
  data: AsignarUsuariosDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return AreaRepo.asignarUsuarios(areaId, data.syncUsuarioIds, userId);
};

export const AreaService = {
  getAll: _getAll,
  create: _create,
  update: _update,
  remove: _remove,
  getUsuarios: _getUsuarios,
  asignarUsuarios: _asignarUsuarios,
};
