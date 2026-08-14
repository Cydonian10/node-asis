import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    CrearDiaDto:
 *      type: object
 *      required:
 *        - diaId
 *      properties:
 *        diaId:
 *          type: integer
 *          example: 1
 *        orden:
 *          type: integer
 *          example: 1
 *        vigenciaGrupoId:
 *          type: integer
 *          nullable: true
 *          description: Grupo de vigencia al que pertenece el dia (requerido si el horario es rotativo).
 */
export const CrearDiaSchema = z
  .object({
    diaId: z
      .number({ message: 'diaId es requerido' })
      .int()
      .positive({ message: 'diaId debe ser mayor a 0' }),
    orden: z
      .number({ message: 'orden es requerido' })
      .int()
      .min(0, { message: 'orden no puede ser negativo' })
      .optional(),
    vigenciaGrupoId: z
      .number({ message: 'vigenciaGrupoId debe ser un número' })
      .int()
      .positive({ message: 'vigenciaGrupoId debe ser mayor a 0' })
      .nullable()
      .optional(),
  })
  .strict();
