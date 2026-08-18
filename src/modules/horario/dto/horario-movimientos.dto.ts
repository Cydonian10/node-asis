/**
 * @swagger
 * components:
 *  schemas:
 *    HorarioMovimientos:
 *      type: object
 *      description: Estado de movimientos de un horario para validar ediciones de estructura.
 *      properties:
 *        turnosBloqueados:
 *          type: array
 *          description: Turnos que ya tienen Asistencia, TurnoModificado o estan ligados a una
 *                       Licencia/Permiso/Justificacion via TurnoId (no se pueden modificar sus
 *                       horas, dia de salida ni eliminarse).
 *          items:
 *            type: integer
 *        estructuraBloqueada:
 *          type: boolean
 *          description: True si el horario tiene cualquier movimiento (asistencias, turnos
 *                       modificados o licencias/permisos/justificaciones/vacaciones de usuarios
 *                       asignados). En ese caso no se pueden agregar dias/grupos ni cambiar el tipo.
 *        tieneAsistencias:
 *          type: boolean
 *        tieneTurnosModificados:
 *          type: boolean
 *        tieneLicencias:
 *          type: boolean
 *        tienePermisos:
 *          type: boolean
 *        tieneVacaciones:
 *          type: boolean
 *        tieneJustificaciones:
 *          type: boolean
 */
export type HorarioMovimientos = {
  turnosBloqueados: number[];
  estructuraBloqueada: boolean;
  tieneAsistencias: boolean;
  tieneTurnosModificados: boolean;
  tieneLicencias: boolean;
  tienePermisos: boolean;
  tieneVacaciones: boolean;
  tieneJustificaciones: boolean;
};