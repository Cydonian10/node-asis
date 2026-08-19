import z from 'zod';
import { DesasignarControlUsuarioSchema } from '../validations/desasignar-control-usuario.validation.js';

export type DesasignarControlUsuarioDto = z.infer<
  typeof DesasignarControlUsuarioSchema
>;
