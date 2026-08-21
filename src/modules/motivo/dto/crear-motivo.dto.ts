import { z } from 'zod';
import { CrearMotivoSchema } from '../validations/crear-motivo.validation.js';

export type CrearMotivoDto = z.infer<typeof CrearMotivoSchema>;
