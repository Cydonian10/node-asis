/**
 * @swagger
 * components:
 *  schemas:
 *    Dia:
 *      type: object
 *      description: Dia del catalogo (7 filas fijas).
 *      properties:
 *        diaId:
 *          type: integer
 *          example: 1
 *        nombre:
 *          type: string
 *          example: Lunes
 *        abreviatura:
 *          type: string
 *          example: Lun
 *        orden:
 *          type: integer
 *          example: 1
 */
export type Dia = {
  diaId: number;
  nombre: string;
  abreviatura: string;
  orden: number;
};
