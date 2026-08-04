/**
 * @swagger
 * components:
 *  schemas:
 *    OperationResult:
 *      type: object
 *      properties:
 *        State:
 *          type: number
 *          description: El estado de la operación (ej. 1 para éxito, 0 para fallo).
 *        Message:
 *          type: string
 *          description: Un mensaje descriptivo del resultado de la operación.
 *        CodeError:
 *          type: "number"
 *          nullable: true
 *          description: Código de error si la operación falló (null si tuvo éxito).
 */
export interface OperationResult {
  State: number;
  Message: string;
  CodeError: number | null;
}

/**
 * @swagger
 * components:
 *  schemas:
 *    OperationResultCreate:
 *      type: object
 *      properties:
 *        Id:
 *          type: number
 *          description: Devuelve el ID generado al insertarse.
 *        State:
 *          type: number
 *          description: El estado de la operación (ej. 1 para éxito, 0 para fallo).
 *        Message:
 *          type: string
 *          description: Un mensaje descriptivo del resultado de la operación.
 *        CodeError:
 *          type: "number"
 *          nullable: true
 *          description: Código de error si la operación falló (null si tuvo éxito).
 */
export interface OperationResultCreate extends OperationResult {
  Id: number | null;
}
