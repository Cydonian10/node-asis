import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import MarcaBiometricoRepo from './repository.js';
import { MarcaBiometrico } from './dto/marca-biometrico.dto.js';
import { CrearMarcaBiometricoDto } from './dto/crear-marca-biometrico.dto.js';
import { ActualizarMarcaBiometricoDto } from './dto/actualizar-marca-biometrico.dto.js';

const getAll = (): Promise<MarcaBiometrico[]> => MarcaBiometricoRepo.getAll();

const getById = (id: number): Promise<MarcaBiometrico | null> =>
  MarcaBiometricoRepo.getById(id);

const create = (data: CrearMarcaBiometricoDto): Promise<OperationResultCreate> =>
  MarcaBiometricoRepo.create(data, authService.getUser().id);

const update = (
  id: number,
  data: ActualizarMarcaBiometricoDto,
): Promise<OperationResult> =>
  MarcaBiometricoRepo.update(id, data, authService.getUser().id);

const remove = (id: number): Promise<OperationResult> =>
  MarcaBiometricoRepo.remove(id, authService.getUser().id);

export const MarcaBiometricoService = {
  getAll,
  getById,
  create,
  update,
  remove,
};
