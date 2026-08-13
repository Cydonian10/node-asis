import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    SyncUsuarioInput:
 *      type: object
 *      description: Usuario a asignar. Si syncUsuarioId es NULL, se crea el SyncUsuarios (requiere usuario).
 *      properties:
 *        syncUsuarioId:
 *          type: integer
 *          nullable: true
 *          example: 100
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
 *    AsignarUsuariosDto:
 *      type: object
 *      required:
 *        - syncUsuarios
 *      properties:
 *        syncUsuarios:
 *          type: array
 *          description: Lista de usuarios a asignar. Minimo 1. Los que ya tienen un area en la
 *                       misma unidad del area destino son rechazados.
 *          items:
 *            $ref: '#/components/schemas/SyncUsuarioInput'
 */
const SyncUsuarioInputSchema = z.object({
  syncUsuarioId: z
    .number({ message: 'syncUsuarioId debe ser un número' })
    .int()
    .positive({ message: 'syncUsuarioId debe ser mayor a 0' })
    .nullable()
    .optional(),
  usuario: z
    .string({ message: 'usuario debe ser un texto' })
    .trim()
    .max(200, { message: 'usuario no puede superar 200 caracteres' })
    .optional(),
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
});

export const AsignarUsuariosSchema = z
  .object({
    syncUsuarios: z
      .array(SyncUsuarioInputSchema, { message: 'syncUsuarios es requerido' })
      .min(1, { message: 'syncUsuarios no puede estar vacío' })
      .refine(
        (items) => {
          const ids = items
            .map((i) => i.syncUsuarioId)
            .filter((id): id is number => id !== undefined && id !== null);
          return new Set(ids).size === ids.length;
        },
        { message: 'syncUsuarioId no puede repetirse' },
      )
      .refine(
        (items) =>
          items.every(
            (i) =>
              i.syncUsuarioId !== undefined || (i.usuario?.length ?? 0) > 0,
          ),
        {
          message:
            'Si syncUsuarioId no se envia, el campo usuario es requerido',
        },
      ),
  })
  .strict();
