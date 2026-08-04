import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    MigrarSyncUnidadDto:
 *      type: object
 *      properties:
 *        syncUnidadId:
 *          type: integer
 *          example: 100
 *          description: Id de la sync a migrar. Si no se envía, migra todos los faltantes.
 */
export const MigrarSyncUnidadSchema = z
  .object({
    syncUnidadId: z
      .number({ message: 'syncUnidadId debe ser un número' })
      .int()
      .positive({ message: 'syncUnidadId debe ser mayor a 0' })
      .optional(),
  })
  .strict();
