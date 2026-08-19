/**
 * @swagger
 * components:
 *   schemas:
 *     TurnoModificado:
 *       type: object
 *       properties:
 *         turnoModificadoId: { type: integer, example: 1 }
 *         turnoId: { type: integer, example: 10 }
 *         usuarioId: { type: integer, example: 25 }
 *         fecha: { type: string, format: date, example: '2026-08-19' }
 *         horaInicio: { type: string, example: '08:00:00' }
 *         horaFin: { type: string, example: '16:00:00' }
 *         motivo: { type: string, nullable: true, example: 'Cita medica' }
 */
export type TurnoModificado = {
  turnoModificadoId: number;
  turnoId: number;
  usuarioId: number;
  fecha: string;
  horaInicio: string;
  horaFin: string;
  motivo: string | null;
};
