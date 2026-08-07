import z from 'zod';
import { CrearHorarioSchema } from '../validations/crear-horario.validation.js';

export type CrearHorarioDto = z.infer<typeof CrearHorarioSchema>;
