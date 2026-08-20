const TurnoModificadoPath = {
  Base: '/turno',

  /**
   * @swagger
   * /turno/{turnoId}/modificar:
   *   get:
   *     tags: [Turnos modificados]
   *     summary: Lista las modificaciones activas de un turno
   *     parameters:
   *       - in: path
   *         name: turnoId
   *         required: true
   *         schema: { type: integer }
   *       - in: query
   *         name: fechaDesde
   *         schema: { type: string, format: date }
   *       - in: query
   *         name: fechaHasta
   *         schema: { type: string, format: date }
   *       - in: query
   *         name: usuarioId
   *         schema: { type: integer }
   *     responses:
   *       200: { description: Lista de modificaciones activas. }
   *       400: { description: Filtros inválidos. }
   */
  GetAll: '/:turnoId/modificar',

  /**
   * @swagger
   * /turno/{turnoId}/modificar:
   *   post:
   *     tags: [Turnos modificados]
   *     summary: Crea una modificación de turno para una fecha
   *     parameters:
   *       - in: path
   *         name: turnoId
   *         required: true
   *         schema: { type: integer }
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema: { $ref: '#/components/schemas/CrearTurnoModificadoDto' }
   *     responses:
   *       201: { description: Modificación creada correctamente. }
   *       400: { description: Datos inválidos o modificación duplicada. }
   */
  Create: '/:turnoId/modificar',

  /**
   * @swagger
   * /turno/{turnoId}/modificar/{turnoModificadoId}:
   *   get:
   *     tags: [Turnos modificados]
   *     summary: Obtiene una modificación de turno
   *     parameters:
   *       - in: path
   *         name: turnoId
   *         required: true
   *         schema: { type: integer }
   *       - in: path
   *         name: turnoModificadoId
   *         required: true
   *         schema: { type: integer }
   *     responses:
   *       200: { description: Modificación encontrada. }
   *       404: { description: Modificación inexistente o perteneciente a otro turno. }
   */
  GetOne: '/:turnoId/modificar/:turnoModificadoId',

  /**
   * @swagger
   * /turno/{turnoId}/modificar/{turnoModificadoId}:
   *   put:
   *     tags: [Turnos modificados]
   *     summary: Actualiza parcialmente una modificación de turno
   *     parameters:
   *       - in: path
   *         name: turnoId
   *         required: true
   *         schema: { type: integer }
   *       - in: path
   *         name: turnoModificadoId
   *         required: true
   *         schema: { type: integer }
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema: { $ref: '#/components/schemas/ActualizarTurnoModificadoDto' }
   *     responses:
   *       200: { description: Modificación actualizada correctamente. }
   *       400: { description: Datos inválidos, pertenencia incorrecta o asistencia existente. }
   */
  Update: '/:turnoId/modificar/:turnoModificadoId',

  /**
   * @swagger
   * /turno/{turnoId}/modificar/{turnoModificadoId}:
   *   delete:
   *     tags: [Turnos modificados]
   *     summary: Elimina lógicamente una modificación de turno
   *     parameters:
   *       - in: path
   *         name: turnoId
   *         required: true
   *         schema: { type: integer }
   *       - in: path
   *         name: turnoModificadoId
   *         required: true
   *         schema: { type: integer }
   *     responses:
   *       200: { description: Modificación eliminada correctamente. }
   *       400: { description: Pertenencia incorrecta o asistencia existente. }
   */
  Delete: '/:turnoId/modificar/:turnoModificadoId',
};

export default TurnoModificadoPath;
