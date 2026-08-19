import z from 'zod';
import { DesasignarControlUnidadSchema } from '../validations/desasignar-control-unidad.validation.js';

export type DesasignarControlUnidadDto = z.infer<
  typeof DesasignarControlUnidadSchema
>;
