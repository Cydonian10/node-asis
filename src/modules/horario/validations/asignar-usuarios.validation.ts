import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    AsignarUsuariosDto:
 *      type: object
 *      required:
 *        - usuarioIds
 *      properties:
 *        usuarioIds:
 *          type: array
 *          description: Lista de ids de Usuario a asignar. Minimo 1 y sin duplicados.
 *          items:
 *            type: integer
 *            example: 5
 *        fechaInicio:
 *          type: string
 *          format: date
 *          description: Fecha desde la que inicia la asignacion.
 *          example: '2026-08-15'
 *        fechaFin:
 *          type: string
 *          format: date
 *          nullable: true
 *          description: Fecha hasta la que aplica la asignacion. Null indica vigencia indefinida.
 *          example: '2026-12-31'
 */
export const AsignarUsuariosSchema = z
  .object({
    usuarioIds: z
      .array(
        z
          .number({ message: 'usuarioIds debe contener solo números' })
          .int()
          .positive({
            message: 'usuarioIds debe contener números mayores a 0',
          }),
        { message: 'usuarioIds es requerido' },
      )
      .min(1, { message: 'usuarioIds no puede estar vacío' })
      .refine((ids) => new Set(ids).size === ids.length, {
        message: 'usuarioIds no puede contener duplicados',
      }),
    fechaInicio: z
      .string({ message: 'fechaInicio es requerida' })
      .regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'fechaInicio debe ser una fecha válida (YYYY-MM-DD)',
      }),
    fechaFin: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'fechaFin debe ser una fecha válida (YYYY-MM-DD)',
      })
      .nullable()
      .optional(),
  })
  .strict()
  .superRefine((data, ctx) => {
    if (data.fechaFin && data.fechaFin < data.fechaInicio) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['fechaFin'],
        message: 'fechaFin no puede ser anterior a fechaInicio',
      });
    }
  });
