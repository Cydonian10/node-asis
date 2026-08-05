import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    AsignarUsuariosDto:
 *      type: object
 *      required:
 *        - syncUsuarioIds
 *      properties:
 *        syncUsuarioIds:
 *          type: array
 *          description: Lista de ids de SyncUsuarios a asignar. Minimo 1 y sin duplicados. Crea el Usuario si no existe.
 *          items:
 *            type: integer
 *            example: 100
 */
export const AsignarUsuariosSchema = z
  .object({
    syncUsuarioIds: z
      .array(
        z
          .number({ message: 'syncUsuarioIds debe contener solo números' })
          .int()
          .positive({
            message: 'syncUsuarioIds debe contener números mayores a 0',
          }),
        { message: 'syncUsuarioIds es requerido' },
      )
      .min(1, { message: 'syncUsuarioIds no puede estar vacío' })
      .refine((ids) => new Set(ids).size === ids.length, {
        message: 'syncUsuarioIds no puede contener duplicados',
      }),
  })
  .strict();
