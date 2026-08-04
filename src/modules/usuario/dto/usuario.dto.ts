import type { z } from 'zod';
import { ActualizarActivoSchema } from '../validations/actualizar-activo.validation.js';
import { MigrarSyncUsuarioSchema } from '../validations/migrar-sync-usuario.validation.js';

/**
 * @swagger
 * components:
 *  schemas:
 *    Usuario:
 *      type: object
 *      description: Usuario migrado (JOIN SyncUsuarios + Usuario).
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
};
