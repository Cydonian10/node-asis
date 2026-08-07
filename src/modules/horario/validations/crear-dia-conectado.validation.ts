import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearDiaConectadoDto:
 *      type: object
 *      required:
 *        - diaId
 *      properties:
 *        diaId:
 *          type: integer
 *          example: 2
 *          description: Id del dia de salida (DiaId) al que se conecta el turno extendido.
 */
export const CrearDiaConectadoSchema = z
  .object({
    diaId: z
      .number({ message: 'diaId es requerido' })
      .int({ message: 'diaId debe ser un entero' })
      .positive({ message: 'diaId debe ser un entero positivo' }),
  })
  .strict();
