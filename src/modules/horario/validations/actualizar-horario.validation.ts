import { z } from 'zod';
import {
  DiaInputSchema,
  GrupoVigenciaInputSchema,
} from './horario-input.schemas.js';

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
 *        dias:
 *          type: array
 *          description: Estructura completa de dias y turnos (no rotativo). Los elementos existentes
 *                       traen horarioDiaId y turnoId; los nuevos solo diaId y turnos.
 *          items:
 *            type: object
 *            properties:
 *              horarioDiaId:
 *                type: integer
 *              diaId:
 *                type: integer
 *              orden:
 *                type: integer
 *              turnos:
 *                type: array
 *                items:
 *                  type: object
 *                  properties:
 *                    turnoId:
 *                      type: integer
 *                    horaInicio:
 *                      type: string
 *                    horaFin:
 *                      type: string
 *                    extendido:
 *                      type: boolean
 *                    diaSalidaId:
 *                      type: integer
 *        grupos:
 *          type: array
 *          description: Estructura completa de grupos de vigencia (rotativo). Los grupos existentes
 *                       traen vigenciaGrupoId; los nuevos no.
 *          items:
 *            type: object
 *            properties:
 *              vigenciaGrupoId:
 *                type: integer
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
 *                    horarioDiaId:
 *                      type: integer
 *                    diaId:
 *                      type: integer
 *                    orden:
 *                      type: integer
 *                    turnos:
 *                      type: array
 *                      items:
 *                        type: object
 *                        properties:
 *                          turnoId:
 *                            type: integer
 *                          horaInicio:
 *                            type: string
 *                          horaFin:
 *                            type: string
 *                          extendido:
 *                            type: boolean
 *                          diaSalidaId:
 *                            type: integer
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
    dias: z
      .array(DiaInputSchema, { message: 'dias debe ser un arreglo' })
      .optional(),
    grupos: z
      .array(GrupoVigenciaInputSchema, { message: 'grupos debe ser un arreglo' })
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
      data.horasLaborales !== undefined ||
      data.dias !== undefined ||
      data.grupos !== undefined,
    { message: 'Debe enviar al menos uno de los campos' },
  )
  .superRefine((data, ctx) => {
    if (data.dias && data.grupos) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['dias'],
        message: 'Solo se puede enviar dias o grupos, no ambos',
      });
    }
    if (data.rotativo === true && data.dias && !data.grupos) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['dias'],
        message: 'Cuando rotativo es true se espera grupos, no dias',
      });
    }
    if (data.rotativo === false && data.grupos && !data.dias) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['grupos'],
        message: 'Cuando rotativo es false se espera dias, no grupos',
      });
    }
    data.grupos?.forEach((grupo, i) => {
      if (grupo.fechaFin && grupo.fechaFin < grupo.fechaInicio) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          path: ['grupos', i, 'fechaFin'],
          message: 'fechaFin no puede ser anterior a fechaInicio',
        });
      }
    });
  });