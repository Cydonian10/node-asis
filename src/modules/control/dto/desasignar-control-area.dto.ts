import z from 'zod';
import { DesasignarControlAreaSchema } from '../validations/desasignar-control-area.validation.js';

export type DesasignarControlAreaDto = z.infer<
  typeof DesasignarControlAreaSchema
>;
