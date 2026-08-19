import z from 'zod';
import { AsignarControlUsuarioSchema } from '../validations/asignar-control-usuario.validation.js';

export type AsignarControlUsuarioDto = z.infer<
  typeof AsignarControlUsuarioSchema
>;
