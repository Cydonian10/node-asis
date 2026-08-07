import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearVigenciaDto:
 *      type: object
 *      required:
 *        - fechaInicio
 *      properties:
 *        fechaInicio:
 *          type: string
 *          format: date
 *          example: "2026-08-10"
 *        fechaFin:
 *          type: string
 *          format: date
 *          nullable: true
 *          example: "2026-08-16"
 */
export const CrearVigenciaSchema = z
  .object({
    fechaInicio: z
      .string({ message: 'fechaInicio es requerido' })
      .regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'fechaInicio debe ser una fecha válida (YYYY-MM-DD)',
      }),
    fechaFin: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'fechaFin debe ser una fecha válida (YYYY-MM-DD)',
      })
      .nullable()
      .optional(),
  })
  .strict();
