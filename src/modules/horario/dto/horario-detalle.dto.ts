/**
 * @swagger
 * components:
 *  schemas:
 *    HorarioDetalle:
 *      type: object
 *      description: Horario con dias, turnos y vigencias anidadas, listo para dibujar en el front.
 *      properties:
 *        horarioId:
 *          type: integer
 *        nombre:
 *          type: string
 *        areaId:
 *          type: integer
 *        areaNombre:
 *          type: string
 *          nullable: true
 *        unidadId:
 *          type: integer
 *          description: Unidad derivada del area (Area.UnidadId).
 *        extendido:
 *          type: boolean
 *        rotativo:
 *          type: boolean
 *        regular:
 *          type: boolean
 *        horasLaborales:
 *          type: integer
 *        dias:
 *          type: array
 *          items:
 *            type: object
 *            properties:
 *              horarioDiaId:
 *                type: integer
 *              diaId:
 *                type: integer
 *              diaNombre:
 *                type: string
 *              orden:
 *                type: integer
 *              vigencia:
 *                type: object
 *                nullable: true
 *                properties:
 *                  vigenciaId:
 *                    type: integer
 *                  fechaInicio:
 *                    type: string
 *                    format: date
 *                    nullable: true
 *                  fechaFin:
 *                    type: string
 *                    format: date
 *                    nullable: true
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
 */
export type HorarioDetalle = {
  horarioId: number;
  nombre: string;
  areaId: number;
  areaNombre: string | null;
  unidadId: number;
  extendido: boolean;
  rotativo: boolean;
  regular: boolean;
  horasLaborales: number;
  dias: {
    horarioDiaId: number;
    diaId: number;
    diaNombre: string;
    orden: number;
    vigencia: {
      vigenciaId: number;
      fechaInicio: string | null;
      fechaFin: string | null;
    } | null;
    turnos: {
      turnoId: number;
      horaInicio: string;
      horaFin: string;
      extendido: boolean;
    }[];
  }[];
  usuarios: {
    horarioAsignacionId: number;
    usuarioId: number;
    syncUsuarioId: number;
    usuario: string;
    nombres: string;
    apellidos: string;
    fechaInicio: string | null;
    fechaFin: string | null;
  }[];
};
