import z from 'zod';
import { AsignarControlUnidadSchema } from '../validations/asignar-control-unidad.validation.js';

export type AsignarControlUnidadDto = z.infer<
  typeof AsignarControlUnidadSchema
>;
