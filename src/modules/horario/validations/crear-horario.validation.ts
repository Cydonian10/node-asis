import { z } from 'zod';
import {
  DiaInputSchema,
  GrupoVigenciaInputSchema,
} from './horario-input.schemas.js';

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
 *          description: Dias del horario con sus turnos. Usado cuando rotativo es false.
 *          items:
 *            type: object
 *            properties:
 *              diaId:
 *                type: integer
 *                example: 1
 *              orden:
 *                type: integer
 *                example: 1
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
*                    diaSalidaId:
*                      type: integer
*                      description: Dia (DiaId maestro) al que sale el turno si es extendido.
*                      example: 2
 *        grupos:
 *          type: array
 *          description: Grupos de vigencia del horario. Usado cuando rotativo es true. Cada grupo
 *                       tiene su rango de fechas y sus propios dias con turnos. Un mismo dia puede
 *                       repetirse en varios grupos con turnos distintos.
 *          items:
 *            type: object
 *            properties:
 *              fechaInicio:
 *                type: string
 *                format: date
 *              fechaFin:
 *                type: string
 *                format: date
 *                nullable: true
 *              dias:
 *                type: array
 *                items:
 *                  type: object
 *                  properties:
 *                    diaId:
 *                      type: integer
 *                    orden:
 *                      type: integer
*                    turnos:
*                      type: array
*                      items:
*                        type: object
*                        properties:
*                          horaInicio:
*                            type: string
*                            example: "08:00"
*                          horaFin:
*                            type: string
*                            example: "16:00"
*                          extendido:
*                            type: boolean
*                          diaSalidaId:
*                            type: integer
*                            description: Dia (DiaId maestro) al que sale el turno si es extendido.
*                            example: 2
 *        usuarioIds:
 *          type: array
 *          description: Opcional. Usuarios a asignar al horario al crearlo.
 *          items:
 *            type: integer
 *        fechaInicio:
 *          type: string
 *          format: date
 *          description: Requerida si se envian usuarioIds.
 *          example: '2026-08-15'
 *        fechaFin:
 *          type: string
 *          format: date
 *          nullable: true
 *          description: Fecha final de la asignacion. Null indica vigencia indefinida.
 *          example: '2026-12-31'
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
      .array(DiaInputSchema, { message: 'dias debe ser un arreglo' })
      .optional(),
    grupos: z
      .array(GrupoVigenciaInputSchema, { message: 'grupos debe ser un arreglo' })
      .optional(),
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
    fechaInicio: z
      .string()
      .regex(/^\d{4}-\d{2}-\d{2}$/, {
        message: 'fechaInicio debe ser una fecha válida (YYYY-MM-DD)',
      })
      .optional(),
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
    if (data.rotativo) {
      if (!data.grupos?.length) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['grupos'],
          message: 'grupos es requerido cuando rotativo es true',
        });
      } else {
        data.grupos.forEach((grupo, i) => {
          if (grupo.fechaFin && grupo.fechaFin < grupo.fechaInicio) {
            ctx.addIssue({
              code: z.ZodIssueCode.custom,
              path: ['grupos', i, 'fechaFin'],
              message: 'fechaFin no puede ser anterior a fechaInicio',
            });
          }
        });
      }
    } else if (!data.dias?.length) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['dias'],
        message: 'dias es requerido cuando rotativo es false',
      });
    }

    if (data.usuarioIds?.length && !data.fechaInicio) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['fechaInicio'],
        message: 'fechaInicio es requerida cuando se asignan usuarios',
      });
    }

    if (data.fechaInicio && data.fechaFin && data.fechaFin < data.fechaInicio) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['fechaFin'],
        message: 'fechaFin no puede ser anterior a fechaInicio',
      });
    }
  });
