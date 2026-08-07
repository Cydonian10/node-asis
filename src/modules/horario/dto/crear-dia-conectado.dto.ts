import z from 'zod';
import { CrearDiaConectadoSchema } from '../validations/crear-dia-conectado.validation.js';

export type CrearDiaConectadoDto = z.infer<typeof CrearDiaConectadoSchema>;
