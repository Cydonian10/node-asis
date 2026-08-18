/**
 * @swagger
 * components:
 *   schemas:
 *     MarcaBiometrico:
 *       type: object
 *       required: [marcaBiometricoId, nombre, tipoDB, detalle]
 *       properties:
 *         marcaBiometricoId:
 *           type: integer
 *           example: 1
 *         nombre:
 *           type: string
 *           example: ZKTeco
 *         tipoDB:
 *           type: string
 *           example: SQLServer
 *         detalle:
 *           type: string
 *           example: Marca de dispositivos de control de acceso
 */
export type MarcaBiometrico = {
  marcaBiometricoId: number;
  nombre: string;
  tipoDB: string;
  detalle: string;
};
