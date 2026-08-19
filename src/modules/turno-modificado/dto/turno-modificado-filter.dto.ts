import z from 'zod';
import { TurnoModificadoFilterSchema } from '../validations/turno-modificado-filter.validation.js';

export type TurnoModificadoFilterDto = z.infer<
  typeof TurnoModificadoFilterSchema
>;
