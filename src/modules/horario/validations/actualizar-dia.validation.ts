import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    ActualizarDiaDto:
 *      type: object
 *      required:
 *        - orden
 *      properties:
 *        orden:
 *          type: integer
 *          example: 2
 */
export const ActualizarDiaSchema = z
  .object({
    orden: z
      .number({ message: 'orden es requerido' })
      .int()
      .min(0, { message: 'orden no puede ser negativo' }),
  })
  .strict();
