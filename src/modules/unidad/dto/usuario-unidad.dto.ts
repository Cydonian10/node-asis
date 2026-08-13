/**
 * @swagger
 * components:
 *  schemas:
 *    UsuarioUnidad:
 *      type: object
 *      description: Usuario de una unidad (derivado por area, JOIN Usuario + Area + SyncUsuarios).
 *      properties:
 *        usuarioId:
 *          type: integer
 *          example: 5
 *          description: Id del usuario (Usuario.UsuarioId).
 *        usuarioAreaId:
 *          type: integer
 *          example: 3
 *          description: Id de la fila UsuarioArea.
 *        syncUsuarioId:
 *          type: integer
 *          example: 100
 *          description: Id del usuario sincronizado (SyncUsuarios.SyncUsuarioId).
 *        areaId:
 *          type: integer
 *          example: 1
 *          description: Id del area del usuario (Usuario.AreaId).
 *        esSupervisor:
 *          type: boolean
 *          example: false
 *          description: Indica si el usuario es supervisor.
 *        usuario:
 *          type: string
 *          example: jperez
 *          description: Nombre de usuario (SyncUsuarios.Usuario).
 *        nombres:
 *          type: string
 *          example: Juan
 *          description: Nombres del usuario (SyncUsuarios.Nombres).
 *        apellidos:
 *          type: string
 *          example: Perez
 *          description: Apellidos del usuario (SyncUsuarios.Apellidos).
 */
export type UsuarioUnidad = {
  usuarioId: number;
  usuarioAreaId: number;
  syncUsuarioId: number;
  areaId: number;
  esSupervisor: boolean;
  usuario: string;
  nombres: string;
  apellidos: string;
};
