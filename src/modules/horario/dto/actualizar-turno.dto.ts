import z from 'zod';
import { ActualizarTurnoSchema } from '../validations/actualizar-turno.validation.js';

export type ActualizarTurnoDto = z.infer<typeof ActualizarTurnoSchema>;
