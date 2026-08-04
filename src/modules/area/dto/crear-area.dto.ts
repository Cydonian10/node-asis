import z from 'zod';
import { CrearAreaSchema } from '../validations/crear-area.validation.js';

export type CrearAreaDto = z.infer<typeof CrearAreaSchema>;
