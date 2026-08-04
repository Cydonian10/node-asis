const UsuarioPath = {
  Base: '/usuarios',

  /**
   * @swagger
   * /usuarios/{id}:
   *  delete:
   *    tags:
   *      - Usuarios
   *    summary: Quita la asignación de un usuario
   *    description: Realiza una eliminación lógica de la asignación del usuario al rol.
   *    parameters:
   *      - in: path
   *        name: id
   *        required: true
   *        description: Id de la asignación (RolUsuario).
   *        schema:
   *          type: integer
   *    responses:
   *      200:
   *        description: Asignación eliminada correctamente.
   *        content:
   *          application/json:
   *            schema:
   *              $ref: '#/components/schemas/OperationResult'
   *      400:
   *        description: Asignación no encontrada.
   *      500:
   *        description: Error interno del servidor.
   */
  Delete: '/:id',
};

export default UsuarioPath;
