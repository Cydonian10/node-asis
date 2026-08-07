import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    ActualizarHorarioDto:
 *      type: object
 *      properties:
 *        nombre:
 *          type: string
 *          example: Turno noche
 *        areaId:
 *          type: integer
 *          example: 6
 *          description: Si cambia el area, las asignaciones incompatibles se limpian.
 *        extendido:
 *          type: boolean
 *        rotativo:
 *          type: boolean
 *        regular:
 *          type: boolean
 *        horasLaborales:
 *          type: integer
 *          example: 10
 */
export const ActualizarHorarioSchema = z
  .object({
    nombre: z
      .string({ message: 'nombre debe ser un string' })
      .min(1, { message: 'nombre no puede estar vacío' })
      .optional(),
    areaId: z
      .number({ message: 'areaId debe ser un número' })
      .int()
      .positive({ message: 'areaId debe ser mayor a 0' })
      .optional(),
    extendido: z
      .boolean({ message: 'extendido debe ser un booleano' })
      .optional(),
    rotativo: z
      .boolean({ message: 'rotativo debe ser un booleano' })
      .optional(),
    regular: z.boolean({ message: 'regular debe ser un booleano' }).optional(),
    horasLaborales: z
      .number({ message: 'horasLaborales debe ser un número' })
      .int()
      .positive({ message: 'horasLaborales debe ser mayor a 0' })
      .optional(),
  })
  .strict()
  .refine(
    (data) =>
      data.nombre !== undefined ||
      data.areaId !== undefined ||
      data.extendido !== undefined ||
      data.rotativo !== undefined ||
      data.regular !== undefined ||
      data.horasLaborales !== undefined,
    { message: 'Debe enviar al menos uno de los campos' },
  );
