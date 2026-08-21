/**
 * @swagger
 * components:
 *  schemas:
 *    ProcesarAsistenciaResultado:
 *      type: object
 *      description: Resumen del procesamiento o cierre de marcaciones.
 *      properties:
 *        procesadas:
 *          type: integer
 *          description: Marcaciones evaluadas.
 *        creadas:
 *          type: integer
 *          description: Asistencias creadas.
 *        actualizadas:
 *          type: integer
 *          description: Asistencias actualizadas (salida registrada o guard).
 *        ignoradas:
 *          type: integer
 *          description: Marcaciones o cierres omitidos por guard, feriado u otra regla aplicable.
 *        errores:
 *          type: array
 *          items:
 *            type: object
 *            properties:
 *              marcacionId:
 *                type: integer
 *              motivo:
 *                type: string
 *        detalle:
 *          type: array
 *          items:
 *            type: object
 *            properties:
 *              marcacionId:
 *                type: integer
 *              asistenciaId:
 *                type: integer
 *                nullable: true
 *              usuarioId:
 *                type: integer
 *              fecha:
 *                type: string
 *                format: date
 *              tipoMarcacion:
 *                type: string
 *                example: entrada
 *              estadoEntrada:
 *                type: string
 *                nullable: true
 *              estadoSalida:
 *                type: string
 *                nullable: true
 *              resultado:
 *                type: string
 *                nullable: true
 *              minutosTarde:
 *                type: integer
 *                nullable: true
 */
export type ProcesarAsistenciaResultado = {
  procesadas: number;
  creadas: number;
  actualizadas: number;
  ignoradas: number;
  errores: { marcacionId: number; motivo: string }[];
  detalle: {
    marcacionId: number;
    asistenciaId: number | null;
    usuarioId: number;
    fecha: string;
    tipoMarcacion: string;
    estadoEntrada: string | null;
    estadoSalida: string | null;
    resultado: string | null;
    minutosTarde?: number;
  }[];
};
