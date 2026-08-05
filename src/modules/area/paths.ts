const AreaPath = {
  Base: '/areas',

  /**
   * @swagger
   * /areas:
   *   get:
   *     tags:
   *       - Areas
   *     summary: Lista areas
   *     description: Lista las areas (JOIN Unidad) con filtros opcionales de unidad y busqueda. Excluye Eliminado = 1.
   *     parameters:
   *       - in: query
   *         name: unidadId
   *         required: false
   *         description: Filtrar por unidad (UnidadId).
   *         schema:
   *           type: integer
   *       - in: query
   *         name: busqueda
   *         required: false
   *         description: Buscar por nombre o descripcion del area.
   *         schema:
   *           type: string
   *     responses:
   *       200:
   *         description: Lista de areas.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/Area'
   *       500:
   *         description: Error interno del servidor.
   */
  GetAll: '/',

  /**
   * @swagger
   * /areas:
   *   post:
   *     tags:
   *       - Areas
   *     summary: Crea un area
   *     description: Crea un area subordinada a una unidad.
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/CrearAreaDto'
   *     responses:
   *       201:
   *         description: Area creada correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResultCreate'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  Create: '/',

  /**
   * @swagger
   * /areas/{id}:
   *   patch:
   *     tags:
   *       - Areas
   *     summary: Actualiza un area
   *     description: Actualiza solo las columnas enviadas (nombre y/o descripcion). Al menos una es requerida.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del area (AreaId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ActualizarAreaDto'
   *     responses:
   *       200:
   *         description: Area actualizada correctamente.
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
   * /areas/{id}:
   *   delete:
   *     tags:
   *       - Areas
   *     summary: Elimina un area
   *     description: Soft-delete del area si no hay restricciones (usuarios del area u Horario). Error si las hay.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del area (AreaId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Area eliminada correctamente.
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
   * /areas/{id}/usuarios-batch:
   *   post:
   *     tags:
   *       - Areas
   *     summary: Asigna sync-usuarios a un area
   *     description: Asigna en lote sync-usuarios al area. Crea el Usuario si no existe y asigna AreaId.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del area (AreaId).
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
   * /areas/{id}/usuarios:
   *   get:
   *     tags:
   *       - Areas
   *     summary: Lista usuarios del area
   *     description: Lista los usuarios del area con sus datos de SyncUsuarios y esSupervisor.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del area (AreaId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Lista de usuarios del area.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/UsuarioArea'
   *       500:
   *         description: Error interno del servidor.
   */
  GetUsuarios: '/:id/usuarios',
};

export default AreaPath;
