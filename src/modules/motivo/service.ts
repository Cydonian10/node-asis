import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import MotivoRepo from './repository.js';
import { Motivo } from './dto/motivo.dto.js';
import { CrearMotivoDto } from './dto/crear-motivo.dto.js';
import { ActualizarMotivoDto } from './dto/actualizar-motivo.dto.js';

const getAll = (): Promise<Motivo[]> => MotivoRepo.getAll();

const getById = (id: number): Promise<Motivo | null> => MotivoRepo.getById(id);

const create = (data: CrearMotivoDto): Promise<OperationResultCreate> =>
  MotivoRepo.create(data, authService.getUser().id);

const update = (
  id: number,
  data: ActualizarMotivoDto,
): Promise<OperationResult> =>
  MotivoRepo.update(id, data, authService.getUser().id);

const remove = (id: number): Promise<OperationResult> =>
  MotivoRepo.remove(id, authService.getUser().id);

export const MotivoService = { getAll, getById, create, update, remove };
