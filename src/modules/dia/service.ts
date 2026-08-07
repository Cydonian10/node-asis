import DiaRepo from './repository.js';
import { Dia } from './dto/dia.dto.js';

const _getAll = (): Promise<Dia[]> => {
  return DiaRepo.getAll();
};

export const DiaService = {
  getAll: _getAll,
};
