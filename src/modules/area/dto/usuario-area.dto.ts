/**
 * @swagger
 * components:
 *  schemas:
 *    UsuarioArea:
 *      type: object
 *      description: Usuario asignado a un area (JOIN Usuario + SyncUsuarios).
 *      properties:
 *        usuarioAreaId:
 *          type: integer
 *          example: 1
 *          description: Id de la asignacion (UsuarioArea.UsuarioAreaId).
 *        usuarioId:
 *          type: integer
 *          example: 5
 *          description: Id del usuario (Usuario.UsuarioId).
 *        areaId:
 *          type: integer
 *          example: 1
 *          description: Id del area (UsuarioArea.AreaId).
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
export type UsuarioArea = {
  usuarioAreaId: number;
  usuarioId: number;
  areaId: number;
  usuario: string;
  nombres: string;
  apellidos: string;
};
