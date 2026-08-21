import { z } from 'zod';

/**
 * @swagger
 * components:
 *   schemas:
 *     ActualizarMotivoDto:
 *       type: object
 *       description: Actualizacion parcial. Debe incluir al menos un campo.
 *       properties:
 *         nombre: { type: string, minLength: 1, maxLength: 100, example: Vacaciones personales }
 *         descripcion: { type: string, nullable: true, maxLength: 255, example: Descripcion actualizada }
 *         documentoRequerido: { type: boolean, example: true }
 */
export const ActualizarMotivoSchema = z
  .object({
    nombre: z.string().trim().min(1).max(100).optional(),
    descripcion: z.string().trim().max(255).nullable().optional(),
    documentoRequerido: z.boolean().optional(),
  })
  .strict()
  .refine((data) => Object.keys(data).length > 0, {
    message: 'Debe enviar al menos un campo para actualizar',
  });
