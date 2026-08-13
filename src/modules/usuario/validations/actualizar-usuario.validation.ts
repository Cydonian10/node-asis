import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    ActualizarUsuarioDto:
 *      type: object
 *      properties:
 *        activo:
 *          type: boolean
 *          example: true
 *          description: Nuevo estado activo/inactivo del usuario.
 *        usuarioAreaId:
 *          type: integer
 *          example: 3
 *          description: Id de la fila UsuarioArea. Requerido si se envia areaId o esSupervisor.
 *        areaId:
 *          type: integer
 *          example: 5
 *          description: Nueva area de la fila UsuarioArea (debe pertenecer a la misma unidad).
 *        esSupervisor:
 *          type: boolean
 *          example: true
 *          description: Indica si el usuario es supervisor en esa area.
 */
export const ActualizarUsuarioSchema = z
  .object({
    activo: z.boolean({ message: 'activo debe ser un booleano' }).optional(),
    usuarioAreaId: z
      .number({ message: 'usuarioAreaId debe ser un número' })
      .int()
      .positive({ message: 'usuarioAreaId debe ser mayor a 0' })
      .optional(),
    areaId: z
      .number({ message: 'areaId debe ser un número' })
      .int()
      .positive({ message: 'areaId debe ser mayor a 0' })
      .optional(),
    esSupervisor: z
      .boolean({ message: 'esSupervisor debe ser un booleano' })
      .optional(),
  })
  .strict()
  .refine(
    (data) =>
      data.activo !== undefined ||
      data.usuarioAreaId !== undefined ||
      data.areaId !== undefined ||
      data.esSupervisor !== undefined,
    {
      message:
        'Debe enviar al menos uno de: activo, usuarioAreaId, areaId, esSupervisor',
    },
  )
  .refine(
    (data) =>
      (data.areaId === undefined && data.esSupervisor === undefined) ||
      data.usuarioAreaId !== undefined,
    {
      message: 'usuarioAreaId es requerido para cambiar el area o esSupervisor',
    },
  );
