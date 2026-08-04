import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    MigrarSyncUsuarioDto:
 *      type: object
 *      properties:
 *        syncUsuarioId:
 *          type: integer
 *          example: 100
 *          description: Id del sync a migrar. Si no se envía, migra todos los faltantes.
 */
export const MigrarSyncUsuarioSchema = z
  .object({
    syncUsuarioId: z
      .number({ message: 'syncUsuarioId debe ser un número' })
      .int()
      .positive({ message: 'syncUsuarioId debe ser mayor a 0' })
      .optional(),
  })
  .strict();
