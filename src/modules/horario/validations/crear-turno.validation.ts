import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearTurnoDto:
 *      type: object
 *      required:
 *        - horaInicio
 *        - horaFin
 *      properties:
 *        horaInicio:
 *          type: string
 *          example: "08:00"
 *        horaFin:
 *          type: string
 *          example: "16:00"
 *        extendido:
 *          type: boolean
 *          example: false
 *          description: Si es true, horaFin pasa la medianoche (dia conectado).
 */
export const CrearTurnoSchema = z
  .object({
    horaInicio: z
      .string({ message: 'horaInicio es requerido' })
      .regex(/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/, {
        message: 'horaInicio debe ser una hora válida (HH:mm)',
      }),
    horaFin: z
      .string({ message: 'horaFin es requerido' })
      .regex(/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/, {
        message: 'horaFin debe ser una hora válida (HH:mm)',
      }),
    extendido: z
      .boolean({ message: 'extendido debe ser un booleano' })
      .default(false),
  })
  .strict();
