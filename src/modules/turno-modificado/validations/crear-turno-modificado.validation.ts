import { z } from 'zod';

const dateSchema = z.string().regex(/^\d{4}-\d{2}-\d{2}$/, {
  message: 'fecha debe tener formato YYYY-MM-DD',
});

const timeSchema = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/, {
  message: 'La hora debe tener formato HH:mm o HH:mm:ss',
});

/**
 * @swagger
 * components:
 *   schemas:
 *     CrearTurnoModificadoDto:
 *       type: object
 *       required: [usuarioId, fecha, horaInicio, horaFin]
 *       properties:
 *         usuarioId: { type: integer, example: 25 }
 *         fecha: { type: string, format: date, example: '2026-08-19' }
 *         horaInicio: { type: string, example: '08:00' }
 *         horaFin: { type: string, example: '16:00' }
 *         motivo: { type: string, nullable: true, example: 'Cita medica' }
 */
export const CrearTurnoModificadoSchema = z
  .object({
    usuarioId: z.number().int().positive(),
    fecha: dateSchema,
    horaInicio: timeSchema,
    horaFin: timeSchema,
    motivo: z.string().max(255).optional(),
  })
  .strict();

export { dateSchema, timeSchema };
