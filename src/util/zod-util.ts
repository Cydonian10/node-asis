import { ZodError } from 'zod';
/**
 * @swagger
 * components:
 *   schemas:
 *     ValidationErrorItem:
 *       type: object
 *       required:
 *         - path
 *         - message
 *       properties:
 *         path:
 *           type: array
 *           description: El/los campo(s) que fallaron
 *           items:
 *             type: string
 *         message:
 *           type: string
 *           description: Mensaje de error
 *     ValidationErrorResponse:
 *       type: array
 *       description: Lista de errores de validación de Zod
 *       items:
 *         $ref: '#/components/schemas/ValidationErrorItem'
 */
export function formatZodError(error: ZodError) {
  return error.issues.map(({ path, message }) => ({
    path,
    message,
  }));
}
