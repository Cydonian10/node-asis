import z from 'zod';
import { ActualizarControlSchema } from '../validations/actualizar-control.validation.js';

export type ActualizarControlDto = z.infer<typeof ActualizarControlSchema>;
