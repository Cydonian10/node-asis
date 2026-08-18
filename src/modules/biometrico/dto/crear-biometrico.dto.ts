import z from 'zod';
import { CrearBiometricoSchema } from '../validations/crear-biometrico.validation.js';

export type CrearBiometricoDto = z.infer<typeof CrearBiometricoSchema>;
