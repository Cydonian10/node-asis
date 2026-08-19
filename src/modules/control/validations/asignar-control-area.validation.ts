import { z } from 'zod';

/**
 * @swagger
 * components:
 *   schemas:
 *     AsignarControlAreaDto:
 *       type: object
 *       required: [areaId]
 *       properties:
 *         areaId:
 *           type: integer
 *           minimum: 1
 *           description: Id del area a la que se asigna el control.
 *           example: 1
 */
export const AsignarControlAreaSchema = z
  .object({
    areaId: z
      .number({ message: 'areaId debe ser un número' })
      .int({ message: 'areaId debe ser un entero' })
      .positive({ message: 'areaId debe ser mayor a 0' }),
  })
  .strict();
