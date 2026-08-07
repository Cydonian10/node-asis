import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { Request, Response } from 'express';
import { AsistenciaService } from './service.js';
import { formatZodError } from '@src/util/zod-util.js';
import { ProcesarAsistenciaSchema } from './validations/procesar-asistencia.validation.js';

const procesarMarcaciones = async (req: Request, res: Response) => {
  const parsed = ProcesarAsistenciaSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await AsistenciaService.procesarMarcaciones(parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const reprocesarAsistencias = async (req: Request, res: Response) => {
  const parsed = ProcesarAsistenciaSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await AsistenciaService.reprocesarAsistencias(parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

export default {
  procesarMarcaciones,
  reprocesarAsistencias,
};
