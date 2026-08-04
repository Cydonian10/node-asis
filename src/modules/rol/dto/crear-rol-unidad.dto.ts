import z from 'zod';
import { CrearRolUnidadSchema } from '../validations/crear-rol-unidad.validation.js';

export type CrearRolUnidadDto = z.infer<typeof CrearRolUnidadSchema>;
