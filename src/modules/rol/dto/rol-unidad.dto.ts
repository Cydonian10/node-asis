/**
 * @swagger
 * components:
 *  schemas:
 *    RolUnidad:
 *      type: object
 *      description: Rol del catalogo instanciado en una unidad (JOIN Rol).
 *      properties:
 *        rolUnidadId:
 *          type: integer
 *          example: 1
 *          description: Id del rol-en-unidad (RolUnidad.RolUnidadId).
 *        rolId:
 *          type: integer
 *          example: 1
 *          description: Id del rol del catalogo (RolUnidad.RolId).
 *        unidadId:
 *          type: integer
 *          example: 1
 *          description: Id de la unidad (RolUnidad.UnidadId).
 *        nombre:
 *          type: string
 *          example: Supervisor
 *          description: Nombre del rol (Rol.Nombre).
 *        descripcion:
 *          type: string
 *          nullable: true
 *          example: Rol de supervisión
 *          description: Descripcion del rol (Rol.Descripcion).
 */
export type RolUnidad = {
  rolUnidadId: number;
  rolId: number;
  unidadId: number;
  nombre: string;
  descripcion: string | null;
};
