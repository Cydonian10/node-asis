import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    AsignarUsuariosDto:
 *      type: object
 *      required:
 *        - usuarioIds
 *      properties:
 *        usuarioIds:
 *          type: array
 *          description: Lista de ids de Usuario a asignar. Minimo 1 y sin duplicados.
 *          items:
 *            type: integer
 *            example: 5
 */
export const AsignarUsuariosSchema = z
  .object({
    usuarioIds: z
      .array(
        z
          .number({ message: 'usuarioIds debe contener solo números' })
          .int()
          .positive({
            message: 'usuarioIds debe contener números mayores a 0',
          }),
        { message: 'usuarioIds es requerido' },
      )
      .min(1, { message: 'usuarioIds no puede estar vacío' })
      .refine((ids) => new Set(ids).size === ids.length, {
        message: 'usuarioIds no puede contener duplicados',
      }),
  })
  .strict();
