/**
 * @swagger
 * components:
 *   schemas:
 *     Biometrico:
 *       type: object
 *       required: [biometricoId, marcaBiometricoId, nombre, ip, serie, ubicacion, tarjeta, huella, rostro]
 *       properties:
 *         biometricoId: { type: integer, example: 1 }
 *         marcaBiometricoId: { type: integer, example: 1 }
 *         marcaNombre: { type: string, example: ZKTeco }
 *         nombre: { type: string, example: Control acceso principal }
 *         ip: { type: string, example: 192.168.1.100 }
 *         serie: { type: string, example: ZK123456 }
 *         ubicacion: { type: string, example: Entrada principal }
 *         tarjeta: { type: boolean, example: true }
 *         huella: { type: boolean, example: true }
 *         rostro: { type: boolean, example: false }
 */
export type Biometrico = {
  biometricoId: number;
  marcaBiometricoId: number;
  marcaNombre: string;
  nombre: string;
  ip: string;
  serie: string;
  ubicacion: string;
  tarjeta: boolean;
  huella: boolean;
  rostro: boolean;
};
