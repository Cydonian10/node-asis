/**
 * @swagger
 * components:
 *  schemas:
 *    UsuarioHorarioAsignacion:
 *      type: object
 *      description: Asignacion de un horario a un usuario con su estado calculado.
 *      properties:
 *        horarioAsignacionId:
 *          type: integer
 *        horarioId:
 *          type: integer
 *        horarioNombre:
 *          type: string
 *        areaId:
 *          type: integer
 *        areaNombre:
 *          type: string
 *          nullable: true
 *        fechaInicio:
 *          type: string
 *          format: date
 *          nullable: true
 *        fechaFin:
 *          type: string
 *          format: date
 *          nullable: true
 *        culminacion:
 *          type: boolean
 *          description: true cuando el horario fue marcado como culminado.
 *        estado:
 *          type: string
 *          enum: [activo, vencido, culminado]
 */
export type EstadoAsignacion = 'activo' | 'vencido' | 'culminado';

export type UsuarioHorarioAsignacion = {
  horarioAsignacionId: number;
  horarioId: number;
  horarioNombre: string;
  areaId: number;
  areaNombre: string | null;
  fechaInicio: string | null;
  fechaFin: string | null;
  culminacion: boolean;
  estado: EstadoAsignacion;
};
