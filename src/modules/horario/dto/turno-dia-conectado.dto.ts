/**
 * @swagger
 * components:
 *  schemas:
 *    TurnoDiaConectado:
 *      type: object
 *      description: Dia conectado de un turno (JOIN SalidaTurnoDia + Turno + Dia). Solo existe
 *                   cuando el turno es extendido (Extendido = 1).
 *      properties:
 *        salidaTurnoDiaId:
 *          type: integer
 *          example: 1
 *        turnoId:
 *          type: integer
 *          example: 10
 *        extendido:
 *          type: boolean
 *          example: true
 *        diaId:
 *          type: integer
 *          example: 2
 *        diaNombre:
 *          type: string
 *          example: Martes
 */
export type TurnoDiaConectado = {
  salidaTurnoDiaId: number;
  turnoId: number;
  extendido: boolean;
  diaId: number;
  diaNombre: string;
};
