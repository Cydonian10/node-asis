import { z } from 'zod';
import { ActualizarMotivoSchema } from '../validations/actualizar-motivo.validation.js';

export type ActualizarMotivoDto = z.infer<typeof ActualizarMotivoSchema>;
