/**
 * @swagger
 * components:
 *  schemas:
 *    Unidad:
 *      type: object
 *      description: Unidad migrada (JOIN SyncUnidad + Unidad).
 *      properties:
 *        unidadId:
 *          type: integer
 *          example: 1
 *          description: Id de la unidad en la tabla Unidad.
 *        syncUnidadId:
 *          type: integer
 *          example: 100
 *          description: Id de la unidad sincronizada.
 *        codigo:
 *          type: string
 *          nullable: true
 *          example: ING-001
 *          description: Codigo de la unidad sincronizada.
 *        nombre:
 *          type: string
 *          nullable: true
 *          example: Ingenieria
 *          description: Nombre de la unidad sincronizada.
 *        horasLaborales:
 *          type: integer
 *          example: 8
 *          description: Horas laborales diarias de la unidad.
 *        horasLaboralesTotales:
 *          type: integer
 *          example: 40
 *          description: Horas laborales semanales totales de la unidad.
 */
export type Unidad = {
  unidadId: number;
  syncUnidadId: number;
  codigo: string | null;
  nombre: string | null;
  horasLaborales: number;
  horasLaboralesTotales: number;
};
