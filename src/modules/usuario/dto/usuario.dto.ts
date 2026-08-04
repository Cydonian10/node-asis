import { z } from 'zod';

/**
 * @swagger
 * components:
 *  schemas:
 *    UsuarioDto:
 *      type: object
 *      description: Usuario asignado a un rol dentro de una unidad.
 *      properties:
 *        id:
 *          type: integer
 *          example: 1
 *          description: Id de la asignación (RolUsuario).
 *        usuarioId:
 *          type: integer
 *          example: 100
 *          description: Id del usuario sincronizado.
 *        usuario:
 *          type: string
 *          example: jperez
 *        nombre:
 *          type: string
 *          example: Juan
 *        apellido:
 *          type: string
 *          example: Pérez
 *        dni:
 *          type: string
 *          nullable: true
 *          example: "12345678"
 *        rolId:
 *          type: integer
 *          example: 2
 *        rol:
 *          type: string
 *          example: Docente
 *        unidadId:
 *          type: integer
 *          example: 3
 *        unidad:
 *          type: string
 *          example: Facultad de Ingeniería
 */
export type Usuario = {
  id: number;
  usuarioId: number;
  usuario: string;
  nombre: string;
  apellido: string;
  dni: string | null;
  rolId: number;
  rol: string;
  unidadId: number;
  unidad: string;
};

/**
 * @swagger
 * components:
 *  schemas:
 *    AsignarUsuarioDto:
 *      type: object
 *      required:
 *        - usuarioId
 *        - rolId
 *      properties:
 *        usuarioId:
 *          type: integer
 *          example: 100
 *          description: Id del usuario sincronizado (ver /sync/usuarios).
 *        rolId:
 *          type: integer
 *          example: 2
 *          description: Id del rol (ver /roles).
 */
export const AsignarUsuarioSchema = z
  .object({
    usuarioId: z
      .number({ message: 'usuarioId es requerido' })
      .int()
      .positive({ message: 'usuarioId debe ser mayor a 0' }),
    rolId: z
      .number({ message: 'rolId es requerido' })
      .int()
      .positive({ message: 'rolId debe ser mayor a 0' }),
  })
  .strict();

export type AsignarUsuarioDto = z.infer<typeof AsignarUsuarioSchema>;

/**
 * @swagger
 * components:
 *  schemas:
 *    ActualizarUsuarioDto:
 *      type: object
 *      required:
 *        - rolId
 *      properties:
 *        rolId:
 *          type: integer
 *          example: 4
 *          description: Nuevo rol al que se reasigna el usuario.
 */
export const ActualizarUsuarioSchema = z
  .object({
    rolId: z
      .number({ message: 'rolId es requerido' })
      .int()
      .positive({ message: 'rolId debe ser mayor a 0' }),
  })
  .strict();

export type ActualizarUsuarioDto = z.infer<typeof ActualizarUsuarioSchema>;
