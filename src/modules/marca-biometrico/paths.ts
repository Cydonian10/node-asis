const MarcaBiometricoPath = {
  Base: '/marca-biometrico',

  /**
   * @swagger
   * /marca-biometrico:
   *   get:
   *     tags: [Marcas Biometricas]
   *     summary: Lista las marcas biometricas
   *     responses:
   *       200:
   *         description: Lista de marcas biometricas activas.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/MarcaBiometrico'
   *       500:
   *         description: Error interno del servidor.
   */
  GetAll: '/',

  /**
   * @swagger
   * /marca-biometrico/{id}:
   *   get:
   *     tags: [Marcas Biometricas]
   *     summary: Obtiene una marca biometrica por id
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema: { type: integer }
   *     responses:
   *       200:
   *         description: Marca biometrica encontrada.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/MarcaBiometrico'
   *       400:
   *         description: Id no valido.
   *       404:
   *         description: Marca biometrica no encontrada.
   */
  GetById: '/:id',

  /**
   * @swagger
   * /marca-biometrico:
   *   post:
   *     tags: [Marcas Biometricas]
   *     summary: Crea una marca biometrica
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/CrearMarcaBiometricoDto'
   *     responses:
   *       201:
   *         description: Marca biometrica creada correctamente.
   *       400:
   *         description: Datos invalidos.
   */
  Create: '/',

  /**
   * @swagger
   * /marca-biometrico/{id}:
   *   put:
   *     tags: [Marcas Biometricas]
   *     summary: Actualiza una marca biometrica
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema: { type: integer }
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ActualizarMarcaBiometricoDto'
   *     responses:
   *       200:
   *         description: Marca biometrica actualizada correctamente.
   *       400:
   *         description: Datos invalidos.
   */
  Update: '/:id',

  /**
   * @swagger
   * /marca-biometrico/{id}:
   *   delete:
   *     tags: [Marcas Biometricas]
   *     summary: Elimina logicamente una marca biometrica
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema: { type: integer }
   *     responses:
   *       200:
   *         description: Marca biometrica eliminada correctamente.
   *       400:
   *         description: Datos invalidos.
   */
  Delete: '/:id',
};

export default MarcaBiometricoPath;
