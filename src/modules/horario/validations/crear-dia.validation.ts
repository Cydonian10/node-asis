import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearDiaDto:
 *      type: object
 *      required:
 *        - diaId
 *      properties:
 *        diaId:
 *          type: integer
 *          example: 1
 *        orden:
 *          type: integer
 *          example: 1
 *        vigencia:
 *          type: object
 *          nullable: true
 *          description: Requerida si el horario es rotativo.
 *          properties:
 *            fechaInicio:
 *              type: string
 *              format: date
 *            fechaFin:
 *              type: string
 *              format: date
 *              nullable: true
 */
export const CrearDiaSchema = z
  .object({
    diaId: z
      .number({ message: 'diaId es requerido' })
      .int()
      .positive({ message: 'diaId debe ser mayor a 0' }),
    orden: z
      .number({ message: 'orden es requerido' })
      .int()
      .min(0, { message: 'orden no puede ser negativo' })
      .optional(),
    vigencia: z
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
      .strict()
      .optional(),
  })
  .strict();
