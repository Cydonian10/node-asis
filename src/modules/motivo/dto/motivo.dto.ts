/**
 * @swagger
 * components:
 *   schemas:
 *     Motivo:
 *       type: object
 *       required: [motivoId, nombre, documentoRequerido]
 *       properties:
 *         motivoId: { type: integer, example: 1 }
 *         nombre: { type: string, example: Vacaciones }
 *         descripcion: { type: string, nullable: true, example: Solicitud de vacaciones }
 *         documentoRequerido: { type: boolean, example: false }
 */
export type Motivo = {
  motivoId: number;
  nombre: string;
  descripcion: string | null;
  documentoRequerido: boolean;
};
