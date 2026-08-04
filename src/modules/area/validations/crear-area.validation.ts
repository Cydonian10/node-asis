import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearAreaDto:
 *      type: object
 *      required:
 *        - nombre
 *        - unidadId
 *      properties:
 *        nombre:
 *          type: string
 *          example: Produccion
 *          description: Nombre del area.
 *        descripcion:
 *          type: string
 *          nullable: true
 *          example: Linea de produccion
 *          description: Descripcion del area (opcional).
 *        unidadId:
 *          type: integer
 *          example: 1
 *          description: Id de la unidad a la que pertenece el area (UnidadId).
 */
export const CrearAreaSchema = z
  .object({
    nombre: z
      .string({ message: 'nombre debe ser un string' })
      .trim()
      .min(1, { message: 'nombre es requerido' }),
    descripcion: z
      .string({ message: 'descripcion debe ser un string' })
      .optional(),
    unidadId: z
      .number({ message: 'unidadId debe ser un número' })
      .int()
      .positive({ message: 'unidadId debe ser mayor a 0' }),
  })
  .strict();
