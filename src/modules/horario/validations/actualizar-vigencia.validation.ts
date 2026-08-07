import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    ActualizarVigenciaDto:
 *      type: object
 *      properties:
 *        fechaInicio:
 *          type: string
 *          format: date
 *        fechaFin:
 *          type: string
 *          format: date
 *          nullable: true
 */
export const ActualizarVigenciaSchema = z
  .object({
    fechaInicio: z
      .string({ message: 'fechaInicio debe ser un string' })
      .regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'fechaInicio debe ser una fecha válida (YYYY-MM-DD)',
      })
      .optional(),
    fechaFin: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'fechaFin debe ser una fecha válida (YYYY-MM-DD)',
      })
      .nullable()
      .optional(),
  })
  .strict()
  .refine(
    (data) => data.fechaInicio !== undefined || data.fechaFin !== undefined,
    { message: 'Debe enviar al menos uno de los campos' },
  );
