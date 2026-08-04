import z from 'zod';
import { AsignarUsuariosSchema } from '../validations/asignar-usuarios.validation.js';

export type AsignarUsuariosDto = z.infer<typeof AsignarUsuariosSchema>;
