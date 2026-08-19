import z from 'zod';
import { ActualizarTurnoModificadoSchema } from '../validations/actualizar-turno-modificado.validation.js';

export type ActualizarTurnoModificadoDto = z.infer<
  typeof ActualizarTurnoModificadoSchema
>;
