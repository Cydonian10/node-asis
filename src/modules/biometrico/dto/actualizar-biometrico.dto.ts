import z from 'zod';
import { ActualizarBiometricoSchema } from '../validations/actualizar-biometrico.validation.js';

export type ActualizarBiometricoDto = z.infer<
  typeof ActualizarBiometricoSchema
>;
