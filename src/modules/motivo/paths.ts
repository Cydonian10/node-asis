const MotivoPath = {
  Base: '/motivos',

  /**
   * @swagger
   * /motivos:
   *   get:
   *     tags: [Motivos]
   *     summary: Lista los motivos activos
   *     responses:
   *       200:
   *         description: Lista de motivos activos.
   */
  GetAll: '/',

  /**
   * @swagger
   * /motivos/{id}:
   *   get:
   *     tags: [Motivos]
   *     summary: Obtiene un motivo por id
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema: { type: integer }
   *     responses:
   *       200: { description: Motivo encontrado. }
   *       404: { description: Motivo no encontrado. }
   */
  GetById: '/:id',

  /**
   * @swagger
   * /motivos:
   *   post:
   *     tags: [Motivos]
   *     summary: Crea un motivo
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema: { $ref: '#/components/schemas/CrearMotivoDto' }
   *     responses:
   *       201: { description: Motivo creado correctamente. }
   */
  Create: '/',

  /**
   * @swagger
   * /motivos/{id}:
   *   put:
   *     tags: [Motivos]
   *     summary: Actualiza parcialmente un motivo
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema: { type: integer }
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema: { $ref: '#/components/schemas/ActualizarMotivoDto' }
   *     responses:
   *       200: { description: Motivo actualizado correctamente. }
   */
  Update: '/:id',

  /**
   * @swagger
   * /motivos/{id}:
   *   delete:
   *     tags: [Motivos]
   *     summary: Elimina logicamente un motivo
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema: { type: integer }
   *     responses:
   *       200: { description: Motivo eliminado correctamente. }
   */
  Delete: '/:id',
};

export default MotivoPath;
