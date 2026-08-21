import { z } from 'zod';

/**
 * @swagger
 * components:
 *   schemas:
 *     ActualizarBiometricoDto:
 *       type: object
 *       required: [terminalId, marcaBiometricoId, nombre, ip, serie, ubicacion, tarjeta, huella, rostro]
 *       properties:
 *         marcaBiometricoId: { type: integer, example: 1 }
 *         terminalId: { type: integer, example: 1 }
 *         nombre: { type: string, maxLength: 40, example: Control acceso actualizado }
 *         ip: { type: string, maxLength: 20, example: 192.168.1.101 }
 *         serie: { type: string, maxLength: 20, example: ZK123456 }
 *         ubicacion: { type: string, maxLength: 50, example: Entrada secundaria }
 *         tarjeta: { type: boolean, example: true }
 *         huella: { type: boolean, example: true }
 *         rostro: { type: boolean, example: false }
 */
export const ActualizarBiometricoSchema = z
  .object({
    terminalId: z.number().int().positive(),
    marcaBiometricoId: z.number().int().positive(),
    nombre: z.string().trim().min(1).max(40),
    ip: z.string().trim().min(1).max(20),
    serie: z.string().trim().min(1).max(20),
    ubicacion: z.string().trim().min(1).max(50),
    tarjeta: z.boolean(),
    huella: z.boolean(),
    rostro: z.boolean(),
  })
  .strict();
