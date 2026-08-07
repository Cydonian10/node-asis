import z from 'zod';
import { CrearTurnoSchema } from '../validations/crear-turno.validation.js';

export type CrearTurnoDto = z.infer<typeof CrearTurnoSchema>;
