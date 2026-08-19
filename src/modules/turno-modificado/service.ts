import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import TurnoModificadoRepo from './repository.js';
import { TurnoModificado } from './dto/turno-modificado.dto.js';
import { CrearTurnoModificadoDto } from './dto/crear-turno-modificado.dto.js';
import { ActualizarTurnoModificadoDto } from './dto/actualizar-turno-modificado.dto.js';
import { TurnoModificadoFilterDto } from './dto/turno-modificado-filter.dto.js';

const getAll = (
  turnoId: number,
  filters: TurnoModificadoFilterDto,
): Promise<TurnoModificado[]> => TurnoModificadoRepo.getAll(turnoId, filters);

const getById = (
  turnoId: number,
  turnoModificadoId: number,
): Promise<TurnoModificado | null> =>
  TurnoModificadoRepo.getById(turnoId, turnoModificadoId);

const create = (
  turnoId: number,
  data: CrearTurnoModificadoDto,
): Promise<OperationResultCreate> =>
  TurnoModificadoRepo.create(turnoId, data, authService.getUser().id);

const update = (
  turnoId: number,
  turnoModificadoId: number,
  data: ActualizarTurnoModificadoDto,
): Promise<OperationResult> =>
  TurnoModificadoRepo.update(
    turnoId,
    turnoModificadoId,
    data,
    authService.getUser().id,
  );

const remove = (
  turnoId: number,
  turnoModificadoId: number,
): Promise<OperationResult> =>
  TurnoModificadoRepo.remove(
    turnoId,
    turnoModificadoId,
    authService.getUser().id,
  );

export const TurnoModificadoService = {
  getAll,
  getById,
  create,
  update,
  remove,
};
