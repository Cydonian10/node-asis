/**
 * @swagger
 * components:
 *  schemas:
 *    SyncUsuario:
 *      type: object
 *      description: Registro de SyncUsuarios con indicador de migración.
 *      properties:
 *        syncUsuarioId:
 *          type: integer
 *          example: 100
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
 *        migrado:
 *          type: boolean
 *          example: false
 *          description: Indica si el sync ya tiene una fila en Usuario.
 */
export type SyncUsuario = {
  syncUsuarioId: number;
  usuario: string;
  nombres: string;
  apellidos: string;
  dni: string | null;
  tipo: string | null;
  migrado: boolean;
};