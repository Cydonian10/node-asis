import { z } from 'zod';
import { dateSchema, timeSchema } from './crear-turno-modificado.validation.js';

/**
 * @swagger
 * components:
 *   schemas:
 *     ActualizarTurnoModificadoDto:
 *       type: object
 *       description: Actualizacion parcial de una modificacion de turno.
 *       properties:
 *         fecha: { type: string, format: date, example: '2026-08-19' }
 *         horaInicio: { type: string, example: '08:00' }
 *         horaFin: { type: string, example: '16:00' }
 *         motivo: { type: string, nullable: true, example: 'Cambio autorizado' }
 */
export const ActualizarTurnoModificadoSchema = z
  .object({
    fecha: dateSchema.optional(),
    horaInicio: timeSchema.optional(),
    horaFin: timeSchema.optional(),
    motivo: z.string().max(255).optional(),
  })
  .strict()
  .refine((data) => Object.keys(data).length > 0, {
    message: 'Debe enviar al menos un campo para actualizar',
  });
