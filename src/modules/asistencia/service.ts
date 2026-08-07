import AsistenciaRepo from './repository.js';
import { authService } from '@src/common/auth.service.js';
import { ProcesarAsistenciaDto } from './dto/procesar-asistencia.dto.js';
import { ProcesarAsistenciaResultado } from './dto/procesar-asistencia-resultado.dto.js';

const _procesarMarcaciones = (
  data: ProcesarAsistenciaDto,
): Promise<ProcesarAsistenciaResultado> => {
  const userId = authService.getUser().id;
  return AsistenciaRepo.procesarMarcaciones(data, userId);
};

const _reprocesarAsistencias = (
  data: ProcesarAsistenciaDto,
): Promise<ProcesarAsistenciaResultado> => {
  const userId = authService.getUser().id;
  return AsistenciaRepo.reprocesarAsistencias(data, userId);
};

export const AsistenciaService = {
  procesarMarcaciones: _procesarMarcaciones,
  reprocesarAsistencias: _reprocesarAsistencias,
};
