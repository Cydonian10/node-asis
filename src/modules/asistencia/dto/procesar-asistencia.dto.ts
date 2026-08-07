import z from 'zod';
import { ProcesarAsistenciaSchema } from '../validations/procesar-asistencia.validation.js';

export type ProcesarAsistenciaDto = z.infer<typeof ProcesarAsistenciaSchema>;
