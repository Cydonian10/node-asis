const BiometricoPath = {
  Base: '/biometrico',

  /**
   * @swagger
   * /biometrico:
   *   get:
   *     tags: [Biometricos]
   *     summary: Lista los dispositivos biometricos
   *     responses:
   *       200:
   *         description: Lista de dispositivos biometricos activos.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/Biometrico'
   *       500:
   *         description: Error interno del servidor.
   */
  GetAll: '/',

  /**
   * @swagger
   * /biometrico/{id}:
   *   get:
   *     tags: [Biometricos]
   *     summary: Obtiene un dispositivo biometrico por id
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema: { type: integer }
   *     responses:
   *       200:
   *         description: Dispositivo biometrico encontrado.
   *       400:
   *         description: Id no valido.
   *       404:
   *         description: Dispositivo biometrico no encontrado.
   */
  GetById: '/:id',

  /**
   * @swagger
   * /biometrico:
   *   post:
   *     tags: [Biometricos]
   *     summary: Crea un dispositivo biometrico
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/CrearBiometricoDto'
   *     responses:
   *       201:
   *         description: Dispositivo biometrico creado correctamente.
   *       400:
   *         description: Datos invalidos.
   */
  Create: '/',

  /**
   * @swagger
   * /biometrico/{id}:
   *   put:
   *     tags: [Biometricos]
   *     summary: Actualiza un dispositivo biometrico
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
   *             $ref: '#/components/schemas/ActualizarBiometricoDto'
   *     responses:
   *       200:
   *         description: Dispositivo biometrico actualizado correctamente.
   *       400:
   *         description: Datos invalidos.
   */
  Update: '/:id',

  /**
   * @swagger
   * /biometrico/{id}:
   *   delete:
   *     tags: [Biometricos]
   *     summary: Elimina logicamente un dispositivo biometrico
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema: { type: integer }
   *     responses:
   *       200:
   *         description: Dispositivo biometrico eliminado correctamente.
   *       400:
   *         description: Datos invalidos.
   */
  Delete: '/:id',
};

export default BiometricoPath;
