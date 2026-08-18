import z from 'zod';
import { ActualizarMarcaBiometricoSchema } from '../validations/actualizar-marca-biometrico.validation.js';

export type ActualizarMarcaBiometricoDto = z.infer<
  typeof ActualizarMarcaBiometricoSchema
>;
