import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    ActualizarUnidadDto:
 *      type: object
 *      description: Campos a actualizar de la unidad. Al menos uno es requerido.
 *      properties:
 *        horasLaborales:
 *          type: integer
 *          example: 9
 *          description: Nuevas horas laborales diarias de la unidad.
 *        horasLaboralesTotales:
 *          type: integer
 *          example: 45
 *          description: Nuevas horas laborales semanales totales de la unidad.
 */
export const ActualizarUnidadSchema = z
  .object({
    horasLaborales: z
      .number({ message: 'horasLaborales debe ser un número' })
      .int()
      .nonnegative({ message: 'horasLaborales debe ser mayor o igual a 0' })
      .optional(),
    horasLaboralesTotales: z
      .number({ message: 'horasLaboralesTotales debe ser un número' })
      .int()
      .nonnegative({
        message: 'horasLaboralesTotales debe ser mayor o igual a 0',
      })
      .optional(),
  })
  .strict()
  .refine(
    (data) =>
      data.horasLaborales !== undefined ||
      data.horasLaboralesTotales !== undefined,
    {
      message:
        'Al menos uno de los campos (horasLaborales u horasLaboralesTotales) es requerido',
    },
  );
