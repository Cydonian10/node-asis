import z from 'zod';
import { CrearAreasBatchSchema } from '../validations/crear-areas-batch.validation.js';

export type CrearAreasBatchItem = z.infer<typeof CrearAreasBatchSchema>[number];
