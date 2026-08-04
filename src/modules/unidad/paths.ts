const UnidadPath = {
  Base: '/unidades',

  /**
   * @swagger
   * /unidades:
   *   get:
   *     tags:
   *       - Unidades
   *     summary: Lista unidades migradas
   *     description: Lista las unidades migradas (JOIN SyncUnidad + Unidad) con filtro opcional de busqueda.
   *     parameters:
   *       - in: query
   *         name: busqueda
   *         required: false
   *         description: Buscar por codigo o nombre de la unidad.
   *         schema:
   *           type: string
   *     responses:
   *       200:
   *         description: Lista de unidades migradas.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/Unidad'
   *       500:
   *         description: Error interno del servidor.
   */
  GetAll: '/',

  /**
   * @swagger
   * /unidades/sync-unidades:
   *   get:
   *     tags:
   *       - Unidades
   *     summary: Lista unidades sincronizadas
   *     description: Lista todos los registros de SyncUnidad con indicador de migrado.
   *     responses:
   *       200:
   *         description: Lista de unidades sincronizadas.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/SyncUnidad'
   *       500:
   *         description: Error interno del servidor.
   */
  GetAllSync: '/sync-unidades',

  /**
   * @swagger
   * /unidades/{id}:
   *   patch:
   *     tags:
   *       - Unidades
   *     summary: Actualiza las horas laborales de una unidad
   *     description: Actualiza solo las columnas enviadas (HorasLaborales y/o HorasLaboralesTotales). Al menos una es requerida.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id de la unidad (UnidadId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ActualizarUnidadDto'
   *     responses:
   *       200:
   *         description: Unidad actualizada correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  Update: '/:id',

  /**
   * @swagger
   * /unidades/{id}:
   *   delete:
   *     tags:
   *       - Unidades
   *     summary: Elimina una unidad
   *     description: Elimina fisicamente la unidad si no hay restricciones (referencias en UsuarioUnidad, Rol, Horario, ControlUnidad o FeriadoUnidad).
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id de la unidad (UnidadId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Unidad eliminada correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  Delete: '/:id',

  /**
   * @swagger
   * /unidades/migrar:
   *   post:
   *     tags:
   *       - Unidades
   *     summary: Migra sync-unidades a unidades
   *     description: Migra una sync-unidad especifica o todos los faltantes si no se envía syncUnidadId.
   *     requestBody:
   *       required: false
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/MigrarSyncUnidadDto'
   *     responses:
   *       200:
   *         description: Migración ejecutada correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResultCreate'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  Migrar: '/migrar',

  /**
   * @swagger
   * /unidades/{id}/usuarios-batch:
   *   post:
   *     tags:
   *       - Unidades
   *     summary: Asigna usuarios a una unidad
   *     description: Asigna en lote usuarios a la unidad respetando el UNIQUE (no duplica asignaciones).
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id de la unidad (UnidadId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/AsignarUsuariosDto'
   *     responses:
   *       200:
   *         description: Usuarios asignados correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  AsignarUsuarios: '/:id/usuarios-batch',

  /**
   * @swagger
   * /unidades/{id}/areas-batch:
   *   post:
   *     tags:
   *       - Unidades
   *     summary: Crea N areas para una unidad
   *     description: Crea en lote areas todas con UnidadId = :id en una sola llamada.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id de la unidad (UnidadId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       description: Lista de areas a crear.
   *       content:
   *         application/json:
   *           schema:
   *             type: array
   *             items:
   *               $ref: '#/components/schemas/CrearAreasBatchItem'
   *     responses:
   *       201:
   *         description: Areas creadas correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  CrearAreas: '/:id/areas-batch',

  /**
   * @swagger
   * /unidades/{id}/usuarios:
   *   get:
   *     tags:
   *       - Unidades
   *     summary: Lista usuarios asignados a la unidad
   *     description: Lista los usuarios asignados a la unidad con sus datos de SyncUsuarios.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id de la unidad (UnidadId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Lista de usuarios asignados a la unidad.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/UsuarioUnidad'
   *       500:
   *         description: Error interno del servidor.
   */
  GetUsuarios: '/:id/usuarios',
};

export default UnidadPath;
