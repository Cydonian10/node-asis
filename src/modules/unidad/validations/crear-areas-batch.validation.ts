import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearAreasBatchItem:
 *      type: object
 *      description: Item de creacion de areas por lote.
 *      required:
 *        - nombre
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
 */
export const CrearAreasBatchSchema = z
  .array(
    z
      .object({
        nombre: z
          .string({ message: 'nombre debe ser un string' })
          .trim()
          .min(1, { message: 'nombre es requerido' }),
        descripcion: z
          .string({ message: 'descripcion debe ser un string' })
          .optional(),
      })
      .strict(),
    { message: 'El body debe ser un array de áreas' },
  )
  .min(1, { message: 'El array de áreas no puede estar vacío' });
