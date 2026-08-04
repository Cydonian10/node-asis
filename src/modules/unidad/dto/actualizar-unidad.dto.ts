import z from 'zod';
import { ActualizarUnidadSchema } from '../validations/actualizar-unidad.validation.js';

export type ActualizarUnidadDto = z.infer<typeof ActualizarUnidadSchema>;
