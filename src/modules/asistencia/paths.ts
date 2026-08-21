const AsistenciaPath = {
  Base: '/asistencia',

  /**
   * @swagger
   * /asistencia/procesar-marcaciones:
   *   post:
   *     tags:
   *       - Asistencias
   *     summary: Procesa marcaciones nuevas
     *     description: Procesa atomícamente las Marcacion aun no enlazadas en AsistenciaMarcacion.
     *                  Valida terminal y biometrico, resuelve usuario, control y turno vigente, y crea
     *                  o actualiza la asistencia con estados Pendiente, entrada o salida.
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
     *     description: Recalcula estados y ResultadoAsistencia, cierra pendientes y crea faltas o
     *                  guards para turnos finalizados. Los errores individuales no detienen el lote.
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
