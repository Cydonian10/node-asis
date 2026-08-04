import z from 'zod';
import { ActualizarAreaSchema } from '../validations/actualizar-area.validation.js';

export type ActualizarAreaDto = z.infer<typeof ActualizarAreaSchema>;
