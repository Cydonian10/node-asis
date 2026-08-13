/**
 * @swagger
 * components:
 *  schemas:
 *    Area:
 *      type: object
 *      description: Area subordinada a una unidad.
 *      properties:
 *        areaId:
 *          type: integer
 *          example: 1
 *          description: Id del area (Area.AreaId).
 *        unidadId:
 *          type: integer
 *          example: 1
 *          description: Id de la unidad a la que pertenece el area (Area.UnidadId).
 *        unidadNombre:
 *          type: string
 *          nullable: true
 *          example: Planta 1
 *          description: Nombre de la unidad (Unidad.Nombre).
 *        nombre:
 *          type: string
 *          example: Produccion
 *          description: Nombre del area.
 *        descripcion:
 *          type: string
 *          nullable: true
 *          example: Linea de produccion
 *          description: Descripcion del area.
 */
export type Area = {
  areaId: number;
  unidadId: number;
  unidadNombre: string | null;
  nombre: string;
  descripcion: string | null;
};
