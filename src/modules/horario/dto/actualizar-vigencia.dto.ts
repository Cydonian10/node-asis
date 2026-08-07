import z from 'zod';
import { ActualizarVigenciaSchema } from '../validations/actualizar-vigencia.validation.js';

export type ActualizarVigenciaDto = z.infer<typeof ActualizarVigenciaSchema>;
