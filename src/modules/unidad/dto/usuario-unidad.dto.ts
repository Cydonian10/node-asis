/**
 * @swagger
 * components:
 *  schemas:
 *    UsuarioUnidad:
 *      type: object
 *      description: Usuario asignado a una unidad (JOIN Usuario + SyncUsuarios).
 *      properties:
 *        usuarioUnidadId:
 *          type: integer
 *          example: 1
 *          description: Id de la asignacion (UsuarioUnidad.UsuarioUnidadId).
 *        usuarioId:
 *          type: integer
 *          example: 5
 *          description: Id del usuario (Usuario.UsuarioId).
 *        unidadId:
 *          type: integer
 *          example: 1
 *          description: Id de la unidad (UsuarioUnidad.UnidadId).
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
  usuarioUnidadId: number;
  usuarioId: number;
  unidadId: number;
  usuario: string;
  nombres: string;
  apellidos: string;
};
