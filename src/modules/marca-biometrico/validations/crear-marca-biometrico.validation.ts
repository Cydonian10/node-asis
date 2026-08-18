import { z } from 'zod';

/**
 * @swagger
 * components:
 *   schemas:
 *     CrearMarcaBiometricoDto:
 *       type: object
 *       required: [nombre, tipoDB, detalle]
 *       properties:
 *         nombre: { type: string, maxLength: 30, example: ZKTeco }
 *         tipoDB: { type: string, maxLength: 20, example: SQLServer }
 *         detalle: { type: string, maxLength: 50, example: Marca de dispositivos }
 */
export const CrearMarcaBiometricoSchema = z
  .object({
    nombre: z.string().trim().min(1).max(30),
    tipoDB: z.string().trim().min(1).max(20),
    detalle: z.string().trim().min(1).max(50),
  })
  .strict();
