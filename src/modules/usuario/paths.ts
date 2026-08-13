const UsuarioPath = {
  Base: '/usuarios',

  /**
   * @swagger
   * /usuarios:
   *   get:
   *     tags:
   *       - Usuarios
   *     summary: Lista usuarios migrados
   *     description: Lista los usuarios migrados (JOIN SyncUsuarios + Usuario + Area) con filtros opcionales.
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
   *       - in: query
   *         name: areaId
   *         required: false
   *         description: Filtrar por area (AreaId).
   *         schema:
   *           type: integer
   *       - in: query
   *         name: unidadId
   *         required: false
   *         description: Filtrar por unidad (UnidadId derivado del area).
   *         schema:
   *           type: integer
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
   * /usuarios/{id}:
   *   get:
   *     tags:
   *       - Usuarios
   *     summary: Obtiene un usuario por id
   *     description: Devuelve un usuario migrado por su UsuarioId. Excluye Eliminado = 1.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del usuario (UsuarioId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Usuario encontrado.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/Usuario'
   *       400:
   *         description: Id no valido.
   *       404:
   *         description: Usuario no encontrado.
   *       500:
   *         description: Error interno del servidor.
   */
  GetById: '/:id',

  /**
   * @swagger
   * /usuarios/{id}:
   *   patch:
   *     tags:
   *       - Usuarios
   *     summary: Actualiza un usuario
   *     description: Actualiza activo, area y/o esSupervisor de un usuario. Al menos uno es requerido.
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
   *             $ref: '#/components/schemas/ActualizarUsuarioDto'
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
  Update: '/:id',
};

export default UsuarioPath;
