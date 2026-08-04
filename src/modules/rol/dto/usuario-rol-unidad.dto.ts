/**
 * @swagger
 * components:
 *  schemas:
 *    UsuarioRolUnidad:
 *      type: object
 *      description: Usuario con un rol-en-unidad (JOIN UsuarioRol + RolUnidad + Rol + SyncUsuarios).
 *      properties:
 *        usuarioRolId:
 *          type: integer
 *          example: 1
 *          description: Id de la asignacion (UsuarioRol.UsuarioRolId).
 *        usuarioId:
 *          type: integer
 *          example: 5
 *          description: Id del usuario (Usuario.UsuarioId).
 *        rolUnidadId:
 *          type: integer
 *          example: 1
 *          description: Id del rol-en-unidad (UsuarioRol.RolUnidadId).
 *        rolId:
 *          type: integer
 *          example: 1
 *          description: Id del rol del catalogo (Rol.RolId).
 *        rolNombre:
 *          type: string
 *          example: Supervisor
 *          description: Nombre del rol (Rol.Nombre).
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
export type UsuarioRolUnidad = {
  usuarioRolId: number;
  usuarioId: number;
  rolUnidadId: number;
  rolId: number;
  rolNombre: string;
  usuario: string;
  nombres: string;
  apellidos: string;
};
