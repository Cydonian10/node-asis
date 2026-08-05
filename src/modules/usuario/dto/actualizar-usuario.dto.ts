import z from 'zod';
import { ActualizarUsuarioSchema } from '../validations/actualizar-usuario.validation.js';

export type ActualizarUsuarioDto = z.infer<typeof ActualizarUsuarioSchema>;
