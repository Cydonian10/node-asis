import z from 'zod';
import { CrearTurnoModificadoSchema } from '../validations/crear-turno-modificado.validation.js';

export type CrearTurnoModificadoDto = z.infer<
  typeof CrearTurnoModificadoSchema
>;
