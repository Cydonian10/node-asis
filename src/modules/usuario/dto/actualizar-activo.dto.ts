import z from "zod";

/**
 * @swagger
 * components:
 *  schemas:
 *    ActualizarActivoDto:
 *      type: object
 *      required:
 *        - activo
 *      properties:
 *        activo:
 *          type: boolean
 *          example: true
 *          description: Nuevo estado activo/inactivo del usuario.
 */
export const ActualizarActivoSchema = z
  .object({
    activo: z.boolean({ message: 'activo es requerido' }),
  })
  .strict();

export type ActualizarActivoDto = z.infer<typeof ActualizarActivoSchema>;
