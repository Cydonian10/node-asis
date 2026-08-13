import z from 'zod';
import { CrearSyncUsuarioSchema } from '../validations/crear-sync-usuario.validation.js';

export type CrearSyncUsuarioDto = z.infer<typeof CrearSyncUsuarioSchema>;
