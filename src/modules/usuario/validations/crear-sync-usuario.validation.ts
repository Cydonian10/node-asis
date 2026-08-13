import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearSyncUsuarioDto:
 *      type: object
 *      required:
 *        - usuario
 *      properties:
 *        syncUsuarioId:
 *          type: integer
 *          nullable: true
 *          description: Id explicito (opcional; si no se envia se asigna MAX+1).
 *        usuario:
 *          type: string
 *          example: jperez
 *        nombres:
 *          type: string
 *          example: Juan
 *        apellidos:
 *          type: string
 *          example: Perez
 *        tipo:
 *          type: string
 *          nullable: true
 *          example: CO
 *        dni:
 *          type: string
 *          nullable: true
 *          example: "20010001"
 */
export const CrearSyncUsuarioSchema = z
  .object({
    syncUsuarioId: z
      .number({ message: 'syncUsuarioId debe ser un número' })
      .int()
      .positive({ message: 'syncUsuarioId debe ser mayor a 0' })
      .nullable()
      .optional(),
    usuario: z
      .string({ message: 'usuario es requerido' })
      .trim()
      .min(1, { message: 'usuario es requerido' })
      .max(200, { message: 'usuario no puede superar 200 caracteres' }),
    nombres: z
      .string({ message: 'nombres debe ser un texto' })
      .trim()
      .max(200, { message: 'nombres no puede superar 200 caracteres' })
      .optional(),
    apellidos: z
      .string({ message: 'apellidos debe ser un texto' })
      .trim()
      .max(200, { message: 'apellidos no puede superar 200 caracteres' })
      .optional(),
    tipo: z
      .string({ message: 'tipo debe ser un texto' })
      .trim()
      .max(50, { message: 'tipo no puede superar 50 caracteres' })
      .optional(),
    dni: z
      .string({ message: 'dni debe ser un texto' })
      .trim()
      .max(20, { message: 'dni no puede superar 20 caracteres' })
      .optional(),
  })
  .strict();
