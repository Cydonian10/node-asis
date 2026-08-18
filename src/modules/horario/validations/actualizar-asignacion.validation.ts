import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    ActualizarAsignacionDto:
 *      type: object
 *      required:
 *        - fechaFin
 *      properties:
 *        fechaFin:
 *          type: string
 *          format: date
 *          nullable: true
 *          description: Nueva fecha de culminacion (vigencia) de la asignacion. Null indica vigencia indefinida.
 *          example: '2026-12-31'
 */
export const ActualizarAsignacionSchema = z
  .object({
    fechaFin: z
      .string({ message: 'fechaFin debe ser un string' })
      .regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'fechaFin debe ser una fecha válida (YYYY-MM-DD)',
      })
      .nullable(),
  })
  .strict();
