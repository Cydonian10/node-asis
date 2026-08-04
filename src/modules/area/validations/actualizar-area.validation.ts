import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    ActualizarAreaDto:
 *      type: object
 *      description: Campos a actualizar del area. Al menos uno es requerido.
 *      properties:
 *        nombre:
 *          type: string
 *          example: Produccion 2
 *          description: Nuevo nombre del area.
 *        descripcion:
 *          type: string
 *          nullable: true
 *          example: Linea 2
 *          description: Nueva descripcion del area.
 */
export const ActualizarAreaSchema = z
  .object({
    nombre: z.string({ message: 'nombre debe ser un string' }).optional(),
    descripcion: z
      .string({ message: 'descripcion debe ser un string' })
      .optional(),
  })
  .strict()
  .refine(
    (data) => data.nombre !== undefined || data.descripcion !== undefined,
    {
      message: 'Al menos uno de los campos (nombre o descripcion) es requerido',
    },
  );
