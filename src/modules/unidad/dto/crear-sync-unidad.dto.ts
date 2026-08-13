import z from 'zod';
import { CrearSyncUnidadSchema } from '../validations/crear-sync-unidad.validation.js';

export type CrearSyncUnidadDto = z.infer<typeof CrearSyncUnidadSchema>;
