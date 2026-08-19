import z from 'zod';
import { CrearControlSchema } from '../validations/crear-control.validation.js';

export type CrearControlDto = z.infer<typeof CrearControlSchema>;
