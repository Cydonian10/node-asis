import { z } from 'zod';

/**
 * @swagger
 * components:
 *   schemas:
 *     ActualizarControlDto:
 *       type: object
 *       description: Actualizacion parcial. Al menos un campo es requerido.
 *       properties:
 *         tolerancia:
 *           type: integer
 *           minimum: 0
 *           description: Minutos de retraso que todavia cuentan como asistencia.
 *           example: 5
 *         limiteTardanza:
 *           type: integer
 *           minimum: 0
 *           description: Minutos de retraso que todavia cuentan como tardanza y no como falta.
 *           example: 15
 *         limiteFalta:
 *           type: integer
 *           minimum: 0
 *           description: Cantidad maxima de faltas permitidas al mes.
 *           example: 3
 */
export const ActualizarControlSchema = z
  .object({
    tolerancia: z
      .number({ message: 'tolerancia debe ser un número' })
      .int({ message: 'tolerancia debe ser un entero' })
      .min(0, { message: 'tolerancia debe ser mayor o igual a 0' })
      .optional(),
    limiteTardanza: z
      .number({ message: 'limiteTardanza debe ser un número' })
      .int({ message: 'limiteTardanza debe ser un entero' })
      .min(0, { message: 'limiteTardanza debe ser mayor o igual a 0' })
      .optional(),
    limiteFalta: z
      .number({ message: 'limiteFalta debe ser un número' })
      .int({ message: 'limiteFalta debe ser un entero' })
      .min(0, { message: 'limiteFalta debe ser mayor o igual a 0' })
      .optional(),
  })
  .strict()
  .refine((data) => Object.keys(data).length > 0, {
    message: 'Debe enviar al menos un campo para actualizar',
  });
