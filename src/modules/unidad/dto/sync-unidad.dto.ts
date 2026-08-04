/**
 * @swagger
 * components:
 *  schemas:
 *    SyncUnidad:
 *      type: object
 *      description: Registro de SyncUnidad con indicador de migracion.
 *      properties:
 *        syncUnidadId:
 *          type: integer
 *          example: 100
 *        codigo:
 *          type: string
 *          nullable: true
 *          example: ING-001
 *        nombre:
 *          type: string
 *          nullable: true
 *          example: Ingenieria
 *        migrado:
 *          type: boolean
 *          example: false
 *          description: Indica si la sync ya tiene una fila en Unidad.
 */
export type SyncUnidad = {
  syncUnidadId: number;
  codigo: string | null;
  nombre: string | null;
  migrado: boolean;
};
