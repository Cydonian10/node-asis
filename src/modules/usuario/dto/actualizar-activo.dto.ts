import z from 'zod';
import { ActualizarActivoSchema } from '../validations/actualizar-activo.validation.js';

export type ActualizarActivoDto = z.infer<typeof ActualizarActivoSchema>;
