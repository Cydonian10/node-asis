import z from 'zod';
import { MigrarSyncUnidadSchema } from '../validations/migrar-sync-unidad.validation.js';

export type MigrarSyncUnidadDto = z.infer<typeof MigrarSyncUnidadSchema>;
