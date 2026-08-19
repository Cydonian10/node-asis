import z from 'zod';
import { AsignarControlAreaSchema } from '../validations/asignar-control-area.validation.js';

export type AsignarControlAreaDto = z.infer<typeof AsignarControlAreaSchema>;
