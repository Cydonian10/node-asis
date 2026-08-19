import { z } from 'zod';
import { dateSchema } from './crear-turno-modificado.validation.js';

/**
 * @swagger
 * components:
 *   schemas:
 *     TurnoModificadoFilterDto:
 *       type: object
 *       properties:
 *         fechaDesde: { type: string, format: date, example: '2026-08-01' }
 *         fechaHasta: { type: string, format: date, example: '2026-08-31' }
 *         usuarioId: { type: integer, example: 25 }
 */
export const TurnoModificadoFilterSchema = z
  .object({
    fechaDesde: dateSchema.optional(),
    fechaHasta: dateSchema.optional(),
    usuarioId: z.number().int().positive().optional(),
  })
  .strict()
  .refine(
    (data) =>
      !data.fechaDesde ||
      !data.fechaHasta ||
      data.fechaDesde <= data.fechaHasta,
    { message: 'fechaDesde no puede ser posterior a fechaHasta' },
  );
