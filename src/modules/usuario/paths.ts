const UsuarioPath = {
  Base: '/usuarios',

  /**
   * @swagger
   * /usuarios:
   *   get:
   *     tags:
   *       - Usuarios
   *     summary: Lista usuarios migrados
   *     description: Lista los usuarios migrados (JOIN SyncUsuarios + Usuario) con filtros opcionales.
   *     parameters:
   *       - in: query
   *         name: activo
   *         required: false
   *         description: Filtrar por estado activo/inactivo.
   *         schema:
   *           type: boolean
   *       - in: query
   *         name: tipo
   *         required: false
   *         description: Filtrar por tipo de usuario.
   *         schema:
   *           type: string
   *       - in: query
   *         name: busqueda
   *         required: false
   *         description: Buscar por usuario, nombres, apellidos o dni.
   *         schema:
   *           type: string
   *     responses:
   *       200:
   *         description: Lista de usuarios migrados.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/Usuario'
   *       500:
   *         description: Error interno del servidor.
   */
  GetAll: '/',

  /**
   * @swagger
   * /usuarios/sync-usuarios:
   *   get:
   *     tags:
   *       - Usuarios
   *     summary: Lista usuarios sincronizados
   *     description: Lista todos los registros de SyncUsuarios con indicador de migrado.
   *     responses:
   *       200:
   *         description: Lista de usuarios sincronizados.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/SyncUsuario'
   *       500:
   *         description: Error interno del servidor.
   */
  GetAllSync: '/sync-usuarios',

  /**
   * @swagger
   * /usuarios/{id}/activo:
   *   patch:
   *     tags:
   *       - Usuarios
   *     summary: Activa o desactiva un usuario
   *     description: Actualiza la columna Active de un usuario.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del usuario (UsuarioId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ActualizarActivoDto'
   *     responses:
   *       200:
   *         description: Usuario actualizado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  UpdateActivo: '/:id/activo',

  /**
   * @swagger
   * /usuarios/migrar:
   *   post:
   *     tags:
   *       - Usuarios
   *     summary: Migra sync-usuarios a usuarios
   *     description: Migra un sync-usuario específico o todos los faltantes si no se envía syncUsuarioId.
   *     requestBody:
   *       required: false
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/MigrarSyncUsuarioDto'
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
};

export default UsuarioPath;
