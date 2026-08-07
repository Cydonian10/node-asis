import SeedRepo from './repository.js';
import { authService } from '@src/common/auth.service.js';
import { OperationResultCreate } from '@src/common/types/operation-result.js';

const _seedDatos = (): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return SeedRepo.seedDatos(userId);
};

const _deleteSeedDatos = (): Promise<OperationResultCreate> => {
  const userId = authService.getUser().id;
  return SeedRepo.deleteSeedDatos(userId);
};

export const SeedService = {
  seedDatos: _seedDatos,
  deleteSeedDatos: _deleteSeedDatos,
};
