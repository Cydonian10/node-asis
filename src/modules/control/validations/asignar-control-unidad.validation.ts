import { z } from 'zod';

/**
 * @swagger
 * components:
 *   schemas:
 *     AsignarControlUnidadDto:
 *       type: object
 *       required: [unidadId]
 *       properties:
 *         unidadId:
 *           type: integer
 *           minimum: 1
 *           description: Id de la unidad a la que se asigna el control.
 *           example: 1
 */
export const AsignarControlUnidadSchema = z
  .object({
    unidadId: z
      .number({ message: 'unidadId debe ser un número' })
      .int({ message: 'unidadId debe ser un entero' })
      .positive({ message: 'unidadId debe ser mayor a 0' }),
  })
  .strict();
