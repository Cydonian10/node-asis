import { z } from 'zod';

/**
 * @swagger
 * components:
 *   schemas:
 *     CrearMotivoDto:
 *       type: object
 *       required: [nombre]
 *       properties:
 *         nombre: { type: string, minLength: 1, maxLength: 100, example: Vacaciones }
 *         descripcion: { type: string, nullable: true, maxLength: 255, example: Solicitud de vacaciones }
 *         documentoRequerido: { type: boolean, default: false, example: false }
 */
export const CrearMotivoSchema = z
  .object({
    nombre: z.string().trim().min(1).max(100),
    descripcion: z.string().trim().max(255).nullable().optional(),
    documentoRequerido: z.boolean().optional().default(false),
  })
  .strict();
