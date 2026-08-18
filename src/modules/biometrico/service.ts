import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import BiometricoRepo from './repository.js';
import { Biometrico } from './dto/biometrico.dto.js';
import { CrearBiometricoDto } from './dto/crear-biometrico.dto.js';
import { ActualizarBiometricoDto } from './dto/actualizar-biometrico.dto.js';

const getAll = (): Promise<Biometrico[]> => BiometricoRepo.getAll();

const getById = (id: number): Promise<Biometrico | null> =>
  BiometricoRepo.getById(id);

const create = (data: CrearBiometricoDto): Promise<OperationResultCreate> =>
  BiometricoRepo.create(data, authService.getUser().id);

const update = (
  id: number,
  data: ActualizarBiometricoDto,
): Promise<OperationResult> =>
  BiometricoRepo.update(id, data, authService.getUser().id);

const remove = (id: number): Promise<OperationResult> =>
  BiometricoRepo.remove(id, authService.getUser().id);

export const BiometricoService = {
  getAll,
  getById,
  create,
  update,
  remove,
};
