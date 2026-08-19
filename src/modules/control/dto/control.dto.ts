/**
 * @swagger
 * components:
 *   schemas:
 *     ControlAsignacionArea:
 *       type: object
 *       required: [controlAreaId, controlId, areaId]
 *       properties:
 *         controlAreaId: { type: integer, example: 1 }
 *         controlId: { type: integer, example: 1 }
 *         areaId: { type: integer, example: 1 }
 *     ControlAsignacionUnidad:
 *       type: object
 *       required: [controlUnidadId, controlId, unidadId]
 *       properties:
 *         controlUnidadId: { type: integer, example: 1 }
 *         controlId: { type: integer, example: 1 }
 *         unidadId: { type: integer, example: 1 }
 *     ControlAsignacionUsuario:
 *       type: object
 *       required: [controlUsuarioId, controlId, usuarioId]
 *       properties:
 *         controlUsuarioId: { type: integer, example: 1 }
 *         controlId: { type: integer, example: 1 }
 *         usuarioId: { type: integer, example: 1 }
 *     Control:
 *       type: object
 *       required: [controlId, tolerancia, limiteTardanza, limiteFalta]
 *       properties:
 *         controlId:
 *           type: integer
 *           example: 1
 *         tolerancia:
 *           type: integer
 *           description: Minutos de retraso que todavia cuentan como asistencia.
 *           example: 5
 *         limiteTardanza:
 *           type: integer
 *           description: Minutos de retraso que todavia cuentan como tardanza y no como falta.
 *           example: 15
 *         limiteFalta:
 *           type: integer
 *           description: Cantidad maxima de faltas permitidas al mes.
 *           example: 3
 *         areas:
 *           type: array
 *           description: Asignaciones activas del control a areas.
 *           items:
 *             $ref: '#/components/schemas/ControlAsignacionArea'
 *         unidades:
 *           type: array
 *           description: Asignaciones activas del control a unidades.
 *           items:
 *             $ref: '#/components/schemas/ControlAsignacionUnidad'
 *         usuarios:
 *           type: array
 *           description: Asignaciones activas del control a usuarios.
 *           items:
 *             $ref: '#/components/schemas/ControlAsignacionUsuario'
 */
export type ControlAsignacionArea = {
  controlAreaId: number;
  controlId: number;
  areaId: number;
};

export type ControlAsignacionUnidad = {
  controlUnidadId: number;
  controlId: number;
  unidadId: number;
};

export type ControlAsignacionUsuario = {
  controlUsuarioId: number;
  controlId: number;
  usuarioId: number;
};

export type Control = {
  controlId: number;
  tolerancia: number;
  limiteTardanza: number;
  limiteFalta: number;
  areas: ControlAsignacionArea[];
  unidades: ControlAsignacionUnidad[];
  usuarios: ControlAsignacionUsuario[];
};
