import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    ActualizarTurnoDto:
 *      type: object
 *      properties:
 *        horaInicio:
 *          type: string
 *          example: "09:00"
 *        horaFin:
 *          type: string
 *          example: "17:00"
 *        extendido:
 *          type: boolean
 */
export const ActualizarTurnoSchema = z
  .object({
    horaInicio: z
      .string({ message: 'horaInicio debe ser un string' })
      .regex(/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/, {
        message: 'horaInicio debe ser una hora válida (HH:mm)',
      })
      .optional(),
    horaFin: z
      .string({ message: 'horaFin debe ser un string' })
      .regex(/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/, {
        message: 'horaFin debe ser una hora válida (HH:mm)',
      })
      .optional(),
    extendido: z
      .boolean({ message: 'extendido debe ser un booleano' })
      .optional(),
  })
  .strict()
  .refine(
    (data) =>
      data.horaInicio !== undefined ||
      data.horaFin !== undefined ||
      data.extendido !== undefined,
    { message: 'Debe enviar al menos uno de los campos' },
  );
