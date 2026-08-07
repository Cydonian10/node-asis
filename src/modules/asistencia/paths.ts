const AsistenciaPath = {
  Base: '/asistencia',

  /**
   * @swagger
   * /asistencia/procesar-marcaciones:
   *   post:
   *     tags:
   *       - Asistencias
   *     summary: Procesa marcaciones nuevas
   *     description: Procesa las Marcacion aun no enlazadas en AsistenciaMarcacion. Resuelve el
   *                  usuario por DNI, su control, el turno vigente mas cercano, evalúa guards
   *                  (Vacaciones/Licencia/Permisos/Justificaciones) y crea o actualiza la asistencia
   *                  etiquetando cada marca como entrada o salida.
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ProcesarAsistenciaDto'
   *     responses:
   *       200:
   *         description: Resumen del procesamiento.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ProcesarAsistenciaResultado'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  ProcesarMarcaciones: '/procesar-marcaciones',

  /**
   * @swagger
   * /asistencia/reprocesar-asistencias:
   *   post:
   *     tags:
   *       - Asistencias
   *     summary: Re-evalua asistencias existentes
   *     description: Recalcula estados y ResultadoAsistencia de las AsistenciaMarcacion existentes y
   *                  crea asistencias Falta (o guard) para turnos vigentes finalizados sin marca.
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ProcesarAsistenciaDto'
   *     responses:
   *       200:
   *         description: Resumen del reprocesamiento.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/ProcesarAsistenciaResultado'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  ReprocesarAsistencias: '/reprocesar-asistencias',
};

export default AsistenciaPath;
