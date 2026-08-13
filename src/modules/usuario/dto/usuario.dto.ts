/**
 * @swagger
 * components:
 *  schemas:
 *    Usuario:
 *      type: object
 *      description: Usuario migrado (JOIN SyncUsuarios + Usuario + Area).
 *      properties:
 *        usuarioId:
 *          type: integer
 *          example: 1
 *          description: Id del usuario en la tabla Usuario.
 *        syncUsuarioId:
 *          type: integer
 *          example: 100
 *          description: Id del usuario sincronizado.
 *        usuario:
 *          type: string
 *          example: jperez
 *        nombres:
 *          type: string
 *          example: Juan
 *        apellidos:
 *          type: string
 *          example: Pérez
 *        dni:
 *          type: string
 *          nullable: true
 *          example: "12345678"
 *        tipo:
 *          type: string
 *          nullable: true
 *          example: DC
 *        activo:
 *          type: boolean
 *          example: true
 *          description: Estado activo/inactivo del usuario.
 *        areaId:
 *          type: integer
 *          example: 5
 *          description: Area del usuario (AreaId).
 *        areaNombre:
 *          type: string
 *          nullable: true
 *          example: Ingenieria
 *          description: Nombre del area (Area.Nombre).
 *        unidadId:
 *          type: integer
 *          example: 2
 *          description: Unidad derivada del area (Area.UnidadId).
 *        unidadNombre:
 *          type: string
 *          nullable: true
 *          example: Colegio
 *          description: Nombre de la unidad (SyncUnidad.Nombre).
 *        esSupervisor:
 *          type: boolean
 *          example: false
 *          description: Indica si el usuario es supervisor.
 */
export type Usuario = {
  usuarioId: number;
  syncUsuarioId: number;
  usuario: string;
  nombres: string;
  apellidos: string;
  dni: string | null;
  tipo: string | null;
  activo: boolean;
  areaId: number;
  areaNombre: string | null;
  unidadId: number;
  unidadNombre: string | null;
  esSupervisor: boolean;
};
