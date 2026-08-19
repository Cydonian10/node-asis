import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import ControlRepo from './repository.js';
import { Control } from './dto/control.dto.js';
import { CrearControlDto } from './dto/crear-control.dto.js';
import { ActualizarControlDto } from './dto/actualizar-control.dto.js';

export type ControlAssignResult =
  | { ok: true; control: Control }
  | { ok: false; result: OperationResult };

const getAll = (): Promise<Control[]> => ControlRepo.getAll();

const getById = (id: number): Promise<Control | null> =>
  ControlRepo.getById(id);

const create = (data: CrearControlDto): Promise<OperationResultCreate> =>
  ControlRepo.create(data, authService.getUser().id);

const update = (
  id: number,
  data: ActualizarControlDto,
): Promise<OperationResult> =>
  ControlRepo.update(id, data, authService.getUser().id);

const remove = (id: number): Promise<OperationResult> =>
  ControlRepo.remove(id, authService.getUser().id);

async function assignAndGet(
  runAssign: () => Promise<OperationResult>,
  controlId: number,
): Promise<ControlAssignResult> {
  const result = await runAssign();
  if (result.State !== 1) return { ok: false, result };

  const control = await ControlRepo.getById(controlId);
  if (!control) {
    throw new Error('No se pudo obtener el control actualizado');
  }
  return { ok: true, control };
}

const assignArea = (
  controlId: number,
  areaId: number,
): Promise<ControlAssignResult> =>
  assignAndGet(
    () => ControlRepo.assignArea(controlId, areaId, authService.getUser().id),
    controlId,
  );

const assignUnidad = (
  controlId: number,
  unidadId: number,
): Promise<ControlAssignResult> =>
  assignAndGet(
    () =>
      ControlRepo.assignUnidad(controlId, unidadId, authService.getUser().id),
    controlId,
  );

const assignUsuario = (
  controlId: number,
  usuarioId: number,
): Promise<ControlAssignResult> =>
  assignAndGet(
    () =>
      ControlRepo.assignUsuario(controlId, usuarioId, authService.getUser().id),
    controlId,
  );

const unassignArea = (
  controlId: number,
  areaId: number,
): Promise<ControlAssignResult> =>
  assignAndGet(
    () => ControlRepo.unassignArea(controlId, areaId, authService.getUser().id),
    controlId,
  );

const unassignUnidad = (
  controlId: number,
  unidadId: number,
): Promise<ControlAssignResult> =>
  assignAndGet(
    () =>
      ControlRepo.unassignUnidad(controlId, unidadId, authService.getUser().id),
    controlId,
  );

const unassignUsuario = (
  controlId: number,
  usuarioId: number,
): Promise<ControlAssignResult> =>
  assignAndGet(
    () =>
      ControlRepo.unassignUsuario(
        controlId,
        usuarioId,
        authService.getUser().id,
      ),
    controlId,
  );

export const ControlService = {
  getAll,
  getById,
  create,
  update,
  remove,
  assignArea,
  assignUnidad,
  assignUsuario,
  unassignArea,
  unassignUnidad,
  unassignUsuario,
};
