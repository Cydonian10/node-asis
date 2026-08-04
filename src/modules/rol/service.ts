import RolRepo from './repository.js';
import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import { RolCatalog } from './dto/rol.dto.js';
import { RolUnidad } from './dto/rol-unidad.dto.js';
import { UsuarioRolUnidad } from './dto/usuario-rol-unidad.dto.js';
import { CrearRolUnidadDto } from './dto/crear-rol-unidad.dto.js';
import { AsignarUsuariosDto } from './dto/asignar-usuarios.dto.js';

const _getRoles = (): Promise<RolCatalog[]> => {
  return RolRepo.getRoles();
};

const _createRolUnidad = (
  unidadId: number,
  data: CrearRolUnidadDto,
): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return RolRepo.createRolUnidad(unidadId, data, userId);
};

const _getRolUnidadByUnidad = (unidadId: number): Promise<RolUnidad[]> => {
  return RolRepo.getRolUnidadByUnidad(unidadId);
};

const _removeRolUnidad = (rolUnidadId: number): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return RolRepo.removeRolUnidad(rolUnidadId, userId);
};

const _getUsuarios = (rolUnidadId: number): Promise<UsuarioRolUnidad[]> => {
  return RolRepo.getUsuarios(rolUnidadId);
};

const _asignarUsuarios = (
  rolUnidadId: number,
  data: AsignarUsuariosDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return RolRepo.asignarUsuarios(rolUnidadId, data.usuarioIds, userId);
};

export const RolService = {
  getRoles: _getRoles,
  createRolUnidad: _createRolUnidad,
  getRolUnidadByUnidad: _getRolUnidadByUnidad,
  removeRolUnidad: _removeRolUnidad,
  getUsuarios: _getUsuarios,
  asignarUsuarios: _asignarUsuarios,
};
