/**
 * @swagger
 * components:
 *  schemas:
 *    HorarioDetalle:
 *      type: object
 *      description: Horario con grupos de vigencia (rotativo) o dias (no rotativo), turnos y
 *                   usuarios asignados, listo para dibujar en el front.
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
 *          description: Dias del horario. Solo cuando rotativo es false.
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
 *              vigenciaGrupoId:
 *                type: integer
 *                nullable: true
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
 *                    diaSalida:
 *                      type: object
 *                      nullable: true
 *                      description: Dia de salida del turno extendido (solo si extendido = true).
 *                      properties:
 *                        diaId:
 *                          type: integer
 *                        diaNombre:
 *                          type: string
 *        grupos:
 *          type: array
 *          description: Grupos de vigencia del horario. Solo cuando rotativo es true. Cada grupo
 *                       tiene su rango de fechas y sus propios dias con turnos.
 *          items:
 *            type: object
 *            properties:
 *              vigenciaGrupoId:
 *                type: integer
 *              fechaInicio:
 *                type: string
 *                format: date
 *                nullable: true
 *              fechaFin:
 *                type: string
 *                format: date
 *                nullable: true
 *              orden:
 *                type: integer
 *              dias:
 *                type: array
 *                items:
 *                  type: object
 *                  properties:
 *                    horarioDiaId:
 *                      type: integer
 *                    diaId:
 *                      type: integer
 *                    diaNombre:
 *                      type: string
 *                    orden:
 *                      type: integer
 *                    turnos:
 *                      type: array
 *                      items:
 *                        type: object
 *                        properties:
 *                          turnoId:
 *                            type: integer
 *                          horaInicio:
 *                            type: string
 *                          horaFin:
 *                            type: string
 *                          extendido:
 *                            type: boolean
 *                          diaSalida:
 *                            type: object
 *                            nullable: true
 *                            properties:
 *                              diaId:
 *                                type: integer
 *                              diaNombre:
 *                                type: string
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
  dias: HorarioDetalleDia[];
  grupos: {
    vigenciaGrupoId: number;
    fechaInicio: string | null;
    fechaFin: string | null;
    orden: number;
    dias: HorarioDetalleDia[];
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

type HorarioDetalleDia = {
  horarioDiaId: number;
  diaId: number;
  diaNombre: string;
  orden: number;
  vigenciaGrupoId: number | null;
  turnos: {
    turnoId: number;
    horaInicio: string;
    horaFin: string;
    extendido: boolean;
    diaSalida: { diaId: number; diaNombre: string } | null;
  }[];
};
