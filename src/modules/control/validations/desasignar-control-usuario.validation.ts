import { z } from 'zod';

/**
 * @swagger
 * components:
 *   schemas:
 *     DesasignarControlUsuarioDto:
 *       type: object
 *       required: [usuarioId]
 *       properties:
 *         usuarioId:
 *           type: integer
 *           minimum: 1
 *           description: Id del usuario del que se desasigna el control.
 *           example: 1
 */
export const DesasignarControlUsuarioSchema = z
  .object({
    usuarioId: z
      .number({ message: 'usuarioId debe ser un número' })
      .int({ message: 'usuarioId debe ser un entero' })
      .positive({ message: 'usuarioId debe ser mayor a 0' }),
  })
  .strict();
