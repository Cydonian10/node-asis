import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    ProcesarAsistenciaDto:
 *      type: object
 *      properties:
 *        usuarioId:
 *          type: integer
 *          nullable: true
 *          description: Filtra por un usuario especifico. Si no llega, procesa todos.
 *        fecha:
 *          type: string
 *          format: date
 *          nullable: true
 *          description: Filtra por dia (YYYY-MM-DD). Si no llega, procesa todo lo pendiente.
 */
export const ProcesarAsistenciaSchema = z
  .object({
    usuarioId: z
      .number({ message: 'usuarioId debe ser un numero' })
      .int({ message: 'usuarioId debe ser un entero' })
      .positive({ message: 'usuarioId debe ser un entero positivo' })
      .optional(),
    fecha: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'fecha debe ser una fecha válida (YYYY-MM-DD)',
      })
      .optional(),
  })
  .strict();
