import z from 'zod';
import { ActualizarHorarioSchema } from '../validations/actualizar-horario.validation.js';

export type ActualizarHorarioDto = z.infer<typeof ActualizarHorarioSchema>;
