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
import { CrearDiaConectadoDto } from './dto/crear-dia-conectado.dto.js';
import { TurnoDiaConectado } from './dto/turno-dia-conectado.dto.js';
import { HorarioMovimientos } from './dto/horario-movimientos.dto.js';
import { AsignarUsuariosDto } from './dto/asignar-usuarios.dto.js';
import { ActualizarAsignacionDto } from './dto/actualizar-asignacion.dto.js';

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

const _getMovimientos = (horarioId: number): Promise<HorarioMovimientos> => {
  return HorarioRepo.getMovimientos(horarioId);
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

const _getTurnoDiaConectado = (
  turnoId: number,
): Promise<TurnoDiaConectado[]> => {
  return HorarioRepo.getTurnoDiaConectado(turnoId);
};

const _createTurnoDiaConectado = (
  turnoId: number,
  data: CrearDiaConectadoDto,
): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return HorarioRepo.createTurnoDiaConectado(turnoId, data, userId);
};

const _removeTurnoDiaConectado = (id: number): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.removeTurnoDiaConectado(id, userId);
};

const _asignarUsuarios = (
  horarioId: number,
  data: AsignarUsuariosDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.asignarUsuarios(
    horarioId,
    data.usuarioIds,
    data.fechaInicio,
    data.fechaFin,
    userId,
  );
};

const _desasignarUsuario = (
  horarioId: number,
  usuarioId: number,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.desasignarUsuario(horarioId, usuarioId, userId);
};

const _culminarAsignacion = (
  horarioAsignacionId: number,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.culminarAsignacion(horarioAsignacionId, userId);
};

const _actualizarAsignacion = (
  horarioAsignacionId: number,
  data: ActualizarAsignacionDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return HorarioRepo.actualizarAsignacion(
    horarioAsignacionId,
    data.fechaFin,
    userId,
  );
};

export const HorarioService = {
  getAll: _getAll,
  getById: _getById,
  getUsuarios: _getUsuarios,
  getMovimientos: _getMovimientos,
  create: _create,
  update: _update,
  remove: _remove,
  createDia: _createDia,
  updateDia: _updateDia,
  removeDia: _removeDia,
  createTurno: _createTurno,
  updateTurno: _updateTurno,
  removeTurno: _removeTurno,
  getTurnoDiaConectado: _getTurnoDiaConectado,
  createTurnoDiaConectado: _createTurnoDiaConectado,
  removeTurnoDiaConectado: _removeTurnoDiaConectado,
  asignarUsuarios: _asignarUsuarios,
  desasignarUsuario: _desasignarUsuario,
  culminarAsignacion: _culminarAsignacion,
  actualizarAsignacion: _actualizarAsignacion,
};
