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
 *        areaId:
 *          type: integer
 *          example: 5
 *          description: Nueva area del usuario (AreaId).
 *        esSupervisor:
 *          type: boolean
 *          example: true
 *          description: Indica si el usuario es supervisor.
 */
export const ActualizarUsuarioSchema = z
  .object({
    activo: z.boolean({ message: 'activo debe ser un booleano' }).optional(),
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
      data.areaId !== undefined ||
      data.esSupervisor !== undefined,
    { message: 'Debe enviar al menos uno de: activo, areaId, esSupervisor' },
  );
