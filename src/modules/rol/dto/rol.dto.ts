/**
 * @swagger
 * components:
 *  schemas:
 *    Rol:
 *      type: object
 *      description: Rol del catalogo global (fijo).
 *      properties:
 *        rolId:
 *          type: integer
 *          example: 1
 *          description: Id del rol (Rol.RolId).
 *        nombre:
 *          type: string
 *          example: Supervisor
 *          description: Nombre del rol.
 *        descripcion:
 *          type: string
 *          nullable: true
 *          example: Rol de supervisión
 *          description: Descripcion del rol.
 */
export type RolCatalog = {
  rolId: number;
  nombre: string;
  descripcion: string | null;
};
