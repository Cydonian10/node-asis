import HorarioRepo from './repository.js';
import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import { Horario } from './dto/horario.dto.js';
import { HorarioDetalle } from './dto/horario-detalle.dto.js';
import { UsuarioHorario } from './dto/usuario-horario.dto.js';
import { CrearHorarioDto } from './dto/crear-horario.dto.js';
import { ActualizarHorarioDto } from './dto/actualizar-horario.dto.js';
import { CrearDiaDto } from './dto/crear-dia.dto.js';
import { ActualizarDiaDto } from './dto/actualizar-dia.dto.js';
import { CrearTurnoDto } from './dto/crear-turno.dto.js';
import { ActualizarTurnoDto } from './dto/actualizar-turno.dto.js';
import { CrearVigenciaDto } from './dto/crear-vigencia.dto.js';
import { ActualizarVigenciaDto } from './dto/actualizar-vigencia.dto.js';
import { AsignarUsuariosDto } from './dto/asignar-usuarios.dto.js';

const _getAll = (areaId?: number, busqueda?: string): Promise<Horario[]> => {
  return HorarioRepo.getAll(areaId, busqueda);
};

const _getById = async (id: number): Promise<HorarioDetalle | null> => {
  const detalle = await HorarioRepo.getById(id);
  if (!detalle) return null;
  detalle.usuarios = await HorarioRepo.getUsuarios(id);
  return detalle;
};

const _getUsuarios = (horarioId: number): Promise<UsuarioHorario[]> => {
  return HorarioRepo.getUsuarios(horarioId);
};

const _create = (data: CrearHorarioDto): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return HorarioRepo.create(data, userId);
};

const _update = (
  id: number,
  data: ActualizarHorarioDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.update(id, data, userId);
};

const _remove = (id: number): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.remove(id, userId);
};

const _createDia = (
  horarioId: number,
  data: CrearDiaDto,
): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return HorarioRepo.createDia(horarioId, data, userId);
};

const _updateDia = (
  id: number,
  data: ActualizarDiaDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.updateDia(id, data, userId);
};

const _removeDia = (id: number): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.removeDia(id, userId);
};

const _createTurno = (
  horarioDiaId: number,
  data: CrearTurnoDto,
): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return HorarioRepo.createTurno(horarioDiaId, data, userId);
};

const _updateTurno = (
  id: number,
  data: ActualizarTurnoDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.updateTurno(id, data, userId);
};

const _removeTurno = (id: number): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.removeTurno(id, userId);
};

const _createVigencia = (
  horarioDiaId: number,
  data: CrearVigenciaDto,
): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return HorarioRepo.createVigencia(horarioDiaId, data, userId);
};

const _updateVigencia = (
  id: number,
  data: ActualizarVigenciaDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.updateVigencia(id, data, userId);
};

const _removeVigencia = (id: number): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.removeVigencia(id, userId);
};

const _asignarUsuarios = (
  horarioId: number,
  data: AsignarUsuariosDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.asignarUsuarios(horarioId, data.usuarioIds, userId);
};

const _desasignarUsuario = (
  horarioId: number,
  usuarioId: number,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.desasignarUsuario(horarioId, usuarioId, userId);
};

export const HorarioService = {
  getAll: _getAll,
  getById: _getById,
  getUsuarios: _getUsuarios,
  create: _create,
  update: _update,
  remove: _remove,
  createDia: _createDia,
  updateDia: _updateDia,
  removeDia: _removeDia,
  createTurno: _createTurno,
  updateTurno: _updateTurno,
  removeTurno: _removeTurno,
  createVigencia: _createVigencia,
  updateVigencia: _updateVigencia,
  removeVigencia: _removeVigencia,
  asignarUsuarios: _asignarUsuarios,
  desasignarUsuario: _desasignarUsuario,
};
