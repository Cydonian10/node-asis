import z from 'zod';
import { CrearMarcaBiometricoSchema } from '../validations/crear-marca-biometrico.validation.js';

export type CrearMarcaBiometricoDto = z.infer<
  typeof CrearMarcaBiometricoSchema
>;
