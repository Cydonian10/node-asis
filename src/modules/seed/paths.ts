const SeedPath = {
  Base: '/seed',

  /**
   * @swagger
   * /seed:
   *   post:
   *     tags:
   *       - Seed
   *     summary: Crea el seed de datos de prueba
   *     description: Crea 3 unidades (Colegio, Academia, Pre-Academia), sus areas, 3 usuarios con
   *                  horario (uno con turno extendido, uno sin turnos extendidos y uno con permiso),
   *                  vigencias de horario de hoy a fin de anio solo para la unidad Colegio y
   *                  justificaciones. Re-ejecutable (limpia el seed anterior).
   *     responses:
   *       201:
   *         description: Seed creado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResultCreate'
   *       500:
   *         description: Error interno del servidor.
   */
  Create: '/',

  /**
   * @swagger
   * /seed:
   *   delete:
   *     tags:
   *       - Seed
   *     summary: Elimina todo el seed de datos de prueba
   *     description: Elimina las unidades, areas, usuarios, horarios, turnos, vigencias,
   *                  asignaciones, permisos y justificaciones creados por el seed.
   *     responses:
   *       200:
   *         description: Seed eliminado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResultCreate'
   *       500:
   *         description: Error interno del servidor.
   */
  Delete: '/',
};

export default SeedPath;
