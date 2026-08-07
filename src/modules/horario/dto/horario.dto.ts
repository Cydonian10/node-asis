/**
 * @swagger
 * components:
 *  schemas:
 *    Horario:
 *      type: object
 *      description: Horario (JOIN Area). La unidad se deriva de Area.UnidadId.
 *      properties:
 *        horarioId:
 *          type: integer
 *          example: 1
 *        nombre:
 *          type: string
 *          example: Turno mañana
 *        areaId:
 *          type: integer
 *          example: 5
 *        areaNombre:
 *          type: string
 *          nullable: true
 *          example: Ingenieria
 *        unidadId:
 *          type: integer
 *          example: 2
 *          description: Unidad derivada del area (Area.UnidadId).
 *        extendido:
 *          type: boolean
 *          example: false
 *        rotativo:
 *          type: boolean
 *          example: false
 *        regular:
 *          type: boolean
 *          example: true
 *        horasLaborales:
 *          type: integer
 *          example: 8
 */
export type Horario = {
  horarioId: number;
  nombre: string;
  areaId: number;
  areaNombre: string | null;
  unidadId: number;
  extendido: boolean;
  rotativo: boolean;
  regular: boolean;
  horasLaborales: number;
};
