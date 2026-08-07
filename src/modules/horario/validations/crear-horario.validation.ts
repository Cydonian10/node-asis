import { z } from 'zod';

const TurnoInputSchema = z.object({
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
    .optional(),
});

const DiaInputSchema = z.object({
  diaId: z
    .number({ message: 'diaId es requerido' })
    .int()
    .positive({ message: 'diaId debe ser mayor a 0' }),
  orden: z
    .number({ message: 'orden es requerido' })
    .int()
    .min(0, { message: 'orden no puede ser negativo' })
    .optional(),
  vigencia: z
    .object({
      fechaInicio: z
        .string({ message: 'fechaInicio es requerido' })
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
    .optional(),
  turnos: z
    .array(TurnoInputSchema, { message: 'turnos es requerido' })
    .min(1, { message: 'turnos no puede estar vacío' }),
});

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearHorarioDto:
 *      type: object
 *      required:
 *        - nombre
 *        - areaId
 *        - extendido
 *        - rotativo
 *        - regular
 *        - horasLaborales
 *        - dias
 *      properties:
 *        nombre:
 *          type: string
 *          example: Turno mañana
 *        areaId:
 *          type: integer
 *          example: 5
 *        extendido:
 *          type: boolean
 *          example: false
 *        rotativo:
 *          type: boolean
 *          example: false
 *        regular:
 *          type: boolean
 *          example: true
 *        horasLaborales:
 *          type: integer
 *          example: 8
 *        dias:
 *          type: array
 *          description: Dias del horario. Si rotativo es true, cada dia debe traer su vigencia.
 *          items:
 *            type: object
 *            properties:
 *              diaId:
 *                type: integer
 *                example: 1
 *              orden:
 *                type: integer
 *                example: 1
 *              vigencia:
 *                type: object
 *                nullable: true
 *                properties:
 *                  fechaInicio:
 *                    type: string
 *                    format: date
 *                  fechaFin:
 *                    type: string
 *                    format: date
 *                    nullable: true
 *              turnos:
 *                type: array
 *                items:
 *                  type: object
 *                  properties:
 *                    horaInicio:
 *                      type: string
 *                      example: "08:00"
 *                    horaFin:
 *                      type: string
 *                      example: "16:00"
 *                    extendido:
 *                      type: boolean
 *        usuarioIds:
 *          type: array
 *          description: Opcional. Usuarios a asignar al horario al crearlo.
 *          items:
 *            type: integer
 */
export const CrearHorarioSchema = z
  .object({
    nombre: z
      .string({ message: 'nombre es requerido' })
      .min(1, { message: 'nombre no puede estar vacío' }),
    areaId: z
      .number({ message: 'areaId es requerido' })
      .int()
      .positive({ message: 'areaId debe ser mayor a 0' }),
    extendido: z
      .boolean({ message: 'extendido debe ser un booleano' })
      .default(false),
    rotativo: z
      .boolean({ message: 'rotativo debe ser un booleano' })
      .default(false),
    regular: z
      .boolean({ message: 'regular debe ser un booleano' })
      .default(true),
    horasLaborales: z
      .number({ message: 'horasLaborales es requerido' })
      .int()
      .positive({ message: 'horasLaborales debe ser mayor a 0' })
      .default(8),
    dias: z
      .array(DiaInputSchema, { message: 'dias es requerido' })
      .min(1, { message: 'dias no puede estar vacío' }),
    usuarioIds: z
      .array(
        z
          .number({ message: 'usuarioIds debe contener solo números' })
          .int()
          .positive({
            message: 'usuarioIds debe contener números mayores a 0',
          }),
      )
      .refine((ids) => new Set(ids).size === ids.length, {
        message: 'usuarioIds no puede contener duplicados',
      })
      .optional(),
  })
  .strict()
  .superRefine((data, ctx) => {
    if (data.rotativo) {
      data.dias.forEach((dia, i) => {
        if (!dia.vigencia) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            path: ['dias', i, 'vigencia'],
            message:
              'vigencia es requerida en cada dia cuando rotativo es true',
          });
        }
      });
    }
  });
