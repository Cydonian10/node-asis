import z from 'zod';
import { CrearDiaSchema } from '../validations/crear-dia.validation.js';

export type CrearDiaDto = z.infer<typeof CrearDiaSchema>;
