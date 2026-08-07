import z from 'zod';
import { CrearVigenciaSchema } from '../validations/crear-vigencia.validation.js';

export type CrearVigenciaDto = z.infer<typeof CrearVigenciaSchema>;
