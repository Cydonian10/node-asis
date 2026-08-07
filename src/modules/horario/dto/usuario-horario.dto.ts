/**
 * @swagger
 * components:
 *  schemas:
 *    UsuarioHorario:
 *      type: object
 *      description: Usuario asignado a un horario (JOIN HorarioAsignacion + Usuario + SyncUsuarios).
 *      properties:
 *        horarioAsignacionId:
 *          type: integer
 *          example: 1
 *        usuarioId:
 *          type: integer
 *          example: 5
 *        syncUsuarioId:
 *          type: integer
 *          example: 100
 *        usuario:
 *          type: string
 *          example: jperez
 *        nombres:
 *          type: string
 *          example: Juan
 *        apellidos:
 *          type: string
 *          example: Pérez
 *        fechaInicio:
 *          type: string
 *          format: date
 *          nullable: true
 *        fechaFin:
 *          type: string
 *          format: date
 *          nullable: true
 */
export type UsuarioHorario = {
  horarioAsignacionId: number;
  usuarioId: number;
  syncUsuarioId: number;
  usuario: string;
  nombres: string;
  apellidos: string;
  fechaInicio: string | null;
  fechaFin: string | null;
};
