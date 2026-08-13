import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearSyncUnidadDto:
 *      type: object
 *      required:
 *        - nombre
 *      properties:
 *        syncUnidadId:
 *          type: integer
 *          nullable: true
 *          description: Id explicito (opcional; si no se envia se asigna MAX+1).
 *        codigo:
 *          type: string
 *          nullable: true
 *          example: COL
 *        nombre:
 *          type: string
 *          example: Colegio
 */
export const CrearSyncUnidadSchema = z
  .object({
    syncUnidadId: z
      .number({ message: 'syncUnidadId debe ser un número' })
      .int()
      .positive({ message: 'syncUnidadId debe ser mayor a 0' })
      .nullable()
      .optional(),
    codigo: z
      .string({ message: 'codigo debe ser un texto' })
      .trim()
      .max(50, { message: 'codigo no puede superar 50 caracteres' })
      .optional(),
    nombre: z
      .string({ message: 'nombre es requerido' })
      .trim()
      .min(1, { message: 'nombre es requerido' })
      .max(200, { message: 'nombre no puede superar 200 caracteres' }),
  })
  .strict();
