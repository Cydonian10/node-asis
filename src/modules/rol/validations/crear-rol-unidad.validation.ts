import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearRolUnidadDto:
 *      type: object
 *      required:
 *        - rolId
 *      properties:
 *        rolId:
 *          type: integer
 *          example: 1
 *          description: Id del rol del catalogo a instanciar en la unidad (RolId).
 */
export const CrearRolUnidadSchema = z
  .object({
    rolId: z
      .number({ message: 'rolId debe ser un número' })
      .int()
      .positive({ message: 'rolId debe ser mayor a 0' }),
  })
  .strict();
