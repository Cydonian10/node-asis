const RolPath = {
  Base: '/roles',

  /**
   * @swagger
   * /roles:
   *   get:
   *     tags:
   *       - Roles
   *     summary: Lista el catalogo global de roles
   *     description: Lista el catalogo de roles (3 filas fijas: Supervisor, Asistente, Usuario).
   *     responses:
   *       200:
   *         description: Lista de roles del catalogo.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/Rol'
   *       500:
   *         description: Error interno del servidor.
   */
  GetRoles: '/',

  /**
   * @swagger
   * /roles/unidad/{unidadId}:
   *   post:
   *     tags:
   *       - Roles
   *     summary: Instancia un rol del catalogo en una unidad
   *     description: Crea un RolUnidad para la unidad. No duplica un (RolId, UnidadId) existente.
   *     parameters:
   *       - in: path
   *         name: unidadId
   *         required: true
   *         description: Id de la unidad (UnidadId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/CrearRolUnidadDto'
   *     responses:
   *       201:
   *         description: Rol instanciado en la unidad correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResultCreate'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  CreateRolUnidad: '/unidad/:unidadId',

  /**
   * @swagger
   * /roles/unidad/{unidadId}:
   *   get:
   *     tags:
   *       - Roles
   *     summary: Lista los roles-en-unidad de una unidad
   *     description: Lista los RolUnidad de la unidad (JOIN catalogo Rol).
   *     parameters:
   *       - in: path
   *         name: unidadId
   *         required: true
   *         description: Id de la unidad (UnidadId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Lista de roles de la unidad.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/RolUnidad'
   *       500:
   *         description: Error interno del servidor.
   */
  GetRolUnidadByUnidad: '/unidad/:unidadId',

  /**
   * @swagger
   * /roles/unidad/{rolUnidadId}:
   *   delete:
   *     tags:
   *       - Roles
   *     summary: Elimina un rol-en-unidad
   *     description: Soft-delete del RolUnidad si no hay UsuarioRol activos. Error si los hay.
   *     parameters:
   *       - in: path
   *         name: rolUnidadId
   *         required: true
   *         description: Id del rol-en-unidad (RolUnidadId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Rol de la unidad eliminado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  DeleteRolUnidad: '/unidad/:rolUnidadId',

  /**
   * @swagger
   * /roles/unidad/{rolUnidadId}/usuarios-batch:
   *   post:
   *     tags:
   *       - Roles
   *     summary: Asigna usuarios a un rol-en-unidad
   *     description: Asigna en lote usuarios al rol-en-unidad respetando el UNIQUE (no duplica asignaciones).
   *     parameters:
   *       - in: path
   *         name: rolUnidadId
   *         required: true
   *         description: Id del rol-en-unidad (RolUnidadId).
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
  AsignarUsuarios: '/unidad/:rolUnidadId/usuarios-batch',

  /**
   * @swagger
   * /roles/unidad/{rolUnidadId}/usuarios:
   *   get:
   *     tags:
   *       - Roles
   *     summary: Lista usuarios con un rol-en-unidad
   *     description: Lista los usuarios con ese rol-en-unidad con sus datos de SyncUsuarios.
   *     parameters:
   *       - in: path
   *         name: rolUnidadId
   *         required: true
   *         description: Id del rol-en-unidad (RolUnidadId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Lista de usuarios con el rol-en-unidad.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/UsuarioRolUnidad'
   *       500:
   *         description: Error interno del servidor.
   */
  GetUsuarios: '/unidad/:rolUnidadId/usuarios',
};

export default RolPath;
