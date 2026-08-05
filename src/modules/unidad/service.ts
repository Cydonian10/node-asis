import UnidadRepo from './repository.js';
import { authService } from '@src/common/auth.service.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import { Unidad } from './dto/unidad.dto.js';
import { SyncUnidad } from './dto/sync-unidad.dto.js';
import { ActualizarUnidadDto } from './dto/actualizar-unidad.dto.js';
import { MigrarSyncUnidadDto } from './dto/migrar-sync-unidad.dto.js';
import { UsuarioUnidad } from './dto/usuario-unidad.dto.js';
import { CrearAreasBatchItem } from './dto/crear-areas-batch.dto.js';

const _getAllMigradas = (busqueda?: string): Promise<Unidad[]> => {
  return UnidadRepo.getAllMigradas(busqueda);
};

const _getAllSync = (): Promise<SyncUnidad[]> => {
  return UnidadRepo.getAllSync();
};

const _updateHoras = (
  id: number,
  data: ActualizarUnidadDto,
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return UnidadRepo.updateHoras(id, data, userId);
};

const _remove = (id: number): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return UnidadRepo.remove(id, userId);
};

const _migrar = (data: MigrarSyncUnidadDto): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return UnidadRepo.migrar(data.syncUnidadId, userId);
};

const _getUsuarios = (unidadId: number): Promise<UsuarioUnidad[]> => {
  return UnidadRepo.getUsuarios(unidadId);
};

const _crearAreas = (
  unidadId: number,
  data: CrearAreasBatchItem[],
): Promise<OperationResult> => {
  const userId = authService.getUser().id;
  return UnidadRepo.crearAreas(unidadId, data, userId);
};

export const UnidadService = {
  getAllMigradas: _getAllMigradas,
  getAllSync: _getAllSync,
  updateHoras: _updateHoras,
  remove: _remove,
  migrar: _migrar,
  getUsuarios: _getUsuarios,
  crearAreas: _crearAreas,
};
