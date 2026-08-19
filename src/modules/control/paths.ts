const ControlPath = {
  Base: '/controles',

  /**
   * @swagger
   * /controles:
   *   get:
   *     tags: [Controles]
   *     summary: Lista los controles con sus asignaciones activas de area, unidad y usuario
   *     responses:
   *       200:
   *         description: Lista de controles activos con asignaciones.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/Control'
   *       500:
   *         description: Error interno del servidor.
   */
  GetAll: '/',

  /**
   * @swagger
   * /controles:
   *   post:
   *     tags: [Controles]
   *     summary: Crea un control
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/CrearControlDto'
   *     responses:
   *       201:
   *         description: Control creado correctamente.
   *       400:
   *         description: Datos invalidos.
   */
  Create: '/',

  /**
   * @swagger
   * /controles/{id}:
   *   put:
   *     tags: [Controles]
   *     summary: Actualiza parcialmente un control
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
   *             $ref: '#/components/schemas/ActualizarControlDto'
   *     responses:
   *       200:
   *         description: Control actualizado correctamente.
   *       400:
   *         description: Datos invalidos.
   */
  Update: '/:id',

  /**
   * @swagger
   * /controles/{id}:
   *   delete:
   *     tags: [Controles]
   *     summary: Elimina logicamente un control sin asignaciones activas
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         schema: { type: integer }
   *     responses:
   *       200:
   *         description: Control eliminado correctamente.
   *       400:
   *         description: El control tiene asignaciones activas o no existe.
   */
  Delete: '/:id',

  /**
   * @swagger
   * /controles/{id}/area:
   *   post:
   *     tags: [Controles]
   *     summary: Asigna el control a un area
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
   *             $ref: '#/components/schemas/AsignarControlAreaDto'
   *     responses:
   *       200:
   *         description: Control completo con la asignacion creada.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/Control'
   *       400:
   *         description: El area ya tiene un control asignado o los datos son invalidos.
   */
  AssignArea: '/:id/area',

  /**
   * @swagger
   * /controles/{id}/unidad:
   *   post:
   *     tags: [Controles]
   *     summary: Asigna el control a una unidad
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
   *             $ref: '#/components/schemas/AsignarControlUnidadDto'
   *     responses:
   *       200:
   *         description: Control completo con la asignacion creada.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/Control'
   *       400:
   *         description: La unidad ya tiene un control asignado o los datos son invalidos.
   */
  AssignUnidad: '/:id/unidad',

  /**
   * @swagger
   * /controles/{id}/usuario:
   *   post:
   *     tags: [Controles]
   *     summary: Asigna el control a un usuario
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
   *             $ref: '#/components/schemas/AsignarControlUsuarioDto'
   *     responses:
   *       200:
   *         description: Control completo con la asignacion creada.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/Control'
   *       400:
   *         description: El usuario ya tiene un control asignado o los datos son invalidos.
   */
  AssignUsuario: '/:id/usuario',

  /**
   * @swagger
   * /controles/{id}/area:
   *   delete:
   *     tags: [Controles]
   *     summary: Desasigna el control de un area
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
   *             $ref: '#/components/schemas/DesasignarControlAreaDto'
   *     responses:
   *       200:
   *         description: Control completo sin la asignacion eliminada.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/Control'
   *       400:
   *         description: La asignacion no existe o los datos son invalidos.
   */
  UnassignArea: '/:id/area',

  /**
   * @swagger
   * /controles/{id}/unidad:
   *   delete:
   *     tags: [Controles]
   *     summary: Desasigna el control de una unidad
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
   *             $ref: '#/components/schemas/DesasignarControlUnidadDto'
   *     responses:
   *       200:
   *         description: Control completo sin la asignacion eliminada.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/Control'
   *       400:
   *         description: La asignacion no existe o los datos son invalidos.
   */
  UnassignUnidad: '/:id/unidad',

  /**
   * @swagger
   * /controles/{id}/usuario:
   *   delete:
   *     tags: [Controles]
   *     summary: Desasigna el control de un usuario
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
   *             $ref: '#/components/schemas/DesasignarControlUsuarioDto'
   *     responses:
   *       200:
   *         description: Control completo sin la asignacion eliminada.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/Control'
   *       400:
   *         description: La asignacion no existe o los datos son invalidos.
   */
  UnassignUsuario: '/:id/usuario',
};

export default ControlPath;
