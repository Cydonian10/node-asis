import z from 'zod';
import { ActualizarAsignacionSchema } from '../validations/actualizar-asignacion.validation.js';

export type ActualizarAsignacionDto = z.infer<typeof ActualizarAsignacionSchema>;
