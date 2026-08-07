import z from 'zod';
import { ActualizarDiaSchema } from '../validations/actualizar-dia.validation.js';

export type ActualizarDiaDto = z.infer<typeof ActualizarDiaSchema>;
