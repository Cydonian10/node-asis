const HorarioPath = {
  Base: '/horarios',

  /**
   * @swagger
   * /horarios:
   *   get:
   *     tags:
   *       - Horarios
   *     summary: Lista horarios
   *     description: Lista horarios (JOIN Area) con filtros opcionales de area y busqueda.
   *     parameters:
   *       - in: query
   *         name: areaId
   *         required: false
   *         description: Filtrar por area (AreaId).
   *         schema:
   *           type: integer
   *       - in: query
   *         name: busqueda
   *         required: false
   *         description: Buscar por nombre del horario.
   *         schema:
   *           type: string
   *     responses:
   *       200:
   *         description: Lista de horarios.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/Horario'
   *       500:
   *         description: Error interno del servidor.
   */
  GetAll: '/',

  /**
   * @swagger
   * /horarios:
   *   post:
   *     tags:
   *       - Horarios
   *     summary: Crea un horario con dias, turnos, vigencias y asignacion de usuarios
   *     description: Crea el horario en una transaccion Node.js que orquesta los SPs de horario,
   *                  dias, turnos, vigencias y asignacion. Si rotativo es true, cada dia debe traer
   *                  su vigencia. Los usuarioIds (opcional) se validan contra el area del horario.
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/CrearHorarioDto'
   *     responses:
   *       201:
   *         description: Horario creado correctamente.
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
   * /horarios/{id}:
   *   get:
   *     tags:
   *       - Horarios
   *     summary: Horario detallado
   *     description: Retorna el horario con sus dias, turnos y vigencias anidadas, mas los usuarios
   *                  asignados. Listo para dibujar en el front.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario (HorarioId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Horario detallado.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/HorarioDetalle'
   *       404:
   *         description: El horario no existe.
   *       500:
   *         description: Error interno del servidor.
   */
  GetById: '/:id',

  /**
   * @swagger
   * /horarios/{id}:
   *   patch:
   *     tags:
   *       - Horarios
   *     summary: Actualiza un horario
   *     description: Actualiza solo los campos planos (nombre, areaId, extendido, rotativo, regular,
   *                  horasLaborales). Si cambia el area, limpia las asignaciones de usuarios que ya
   *                  no pertenezcan al nuevo area.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario (HorarioId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ActualizarHorarioDto'
   *     responses:
   *       200:
   *         description: Horario actualizado correctamente.
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
   * /horarios/{id}:
   *   delete:
   *     tags:
   *       - Horarios
   *     summary: Elimina un horario
   *     description: Soft-delete en cascada (horario, dias, turnos, vigencias, asignaciones). Error
   *                  si hay Asistencia o Vacaciones que referencien el horario.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario (HorarioId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Horario eliminado correctamente.
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
   * /horarios/{id}/dias:
   *   post:
   *     tags:
   *       - Horarios
   *     summary: Agrega un dia al horario
   *     description: Crea un HorarioDia. Si el horario es rotativo, debe traer su vigencia.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario (HorarioId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/CrearDiaDto'
   *     responses:
   *       201:
   *         description: Dia agregado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResultCreate'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  CreateDia: '/:id/dias',

  /**
   * @swagger
   * /horarios/{id}/dias/{diaId}:
   *   patch:
   *     tags:
   *       - Horarios
   *     summary: Actualiza el orden de un dia en el horario
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario.
   *         schema:
   *           type: integer
   *       - in: path
   *         name: diaId
   *         required: true
   *         description: Id del HorarioDia.
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ActualizarDiaDto'
   *     responses:
   *       200:
   *         description: Dia del horario actualizado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  UpdateDia: '/:id/dias/:diaId',

  /**
   * @swagger
   * /horarios/{id}/dias/{diaId}:
   *   delete:
   *     tags:
   *       - Horarios
   *     summary: Elimina un dia del horario
   *     description: Soft-delete del HorarioDia y sus turnos y vigencias.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario.
   *         schema:
   *           type: integer
   *       - in: path
   *         name: diaId
   *         required: true
   *         description: Id del HorarioDia.
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Dia del horario eliminado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  DeleteDia: '/:id/dias/:diaId',

  /**
   * @swagger
   * /horarios/{id}/dias/{diaId}/turnos:
   *   post:
   *     tags:
   *       - Horarios
   *     summary: Agrega un turno a un dia del horario
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario.
   *         schema:
   *           type: integer
   *       - in: path
   *         name: diaId
   *         required: true
   *         description: Id del HorarioDia.
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/CrearTurnoDto'
   *     responses:
   *       201:
   *         description: Turno creado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResultCreate'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  CreateTurno: '/:id/dias/:diaId/turnos',

  /**
   * @swagger
   * /horarios/turnos/{turnoId}:
   *   patch:
   *     tags:
   *       - Horarios
   *     summary: Actualiza un turno
   *     parameters:
   *       - in: path
   *         name: turnoId
   *         required: true
   *         description: Id del turno (TurnoId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ActualizarTurnoDto'
   *     responses:
   *       200:
   *         description: Turno actualizado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  UpdateTurno: '/turnos/:turnoId',

  /**
   * @swagger
   * /horarios/turnos/{turnoId}:
   *   delete:
   *     tags:
   *       - Horarios
   *     summary: Elimina un turno
   *     description: Soft-delete del turno.
   *     parameters:
   *       - in: path
   *         name: turnoId
   *         required: true
   *         description: Id del turno (TurnoId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Turno eliminado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  DeleteTurno: '/turnos/:turnoId',

  /**
   * @swagger
   * /horarios/turnos/{turnoId}/dia-conectado:
   *   post:
   *     tags:
   *       - Horarios
   *     summary: Crea el dia conectado de un turno
   *     description: Crea la conexion (SalidaTurnoDia) entre un turno y un dia. Solo se permite si
   *                  el turno tiene Extendido = 1 (HoraFin pasa la medianoche); el SP rechaza la
   *                  operacion si el turno no es extendido.
   *     parameters:
   *       - in: path
   *         name: turnoId
   *         required: true
   *         description: Id del turno (TurnoId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/CrearDiaConectadoDto'
   *     responses:
   *       201:
   *         description: Dia conectado creado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResultCreate'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  CreateTurnoDiaConectado: '/turnos/:turnoId/dia-conectado',

  /**
   * @swagger
   * /horarios/turnos/{turnoId}/dia-conectado:
   *   get:
   *     tags:
   *       - Horarios
   *     summary: Obtiene el dia conectado de un turno
   *     description: Retorna los dias conectados (SalidaTurnoDia) del turno junto con su flag
   *                  Extendido, para verificar si el turno tiene dia conectado.
   *     parameters:
   *       - in: path
   *         name: turnoId
   *         required: true
   *         description: Id del turno (TurnoId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Lista de dias conectados.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/TurnoDiaConectado'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  GetTurnoDiaConectado: '/turnos/:turnoId/dia-conectado',

  /**
   * @swagger
   * /horarios/{id}/dias/{diaId}/vigencias:
   *   post:
   *     tags:
   *       - Horarios
   *     summary: Agrega una vigencia a un dia del horario
   *     description: Define el rango de fechas en el que aplican los turnos del dia. Uso tipico en
   *                  horarios rotativos.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario.
   *         schema:
   *           type: integer
   *       - in: path
   *         name: diaId
   *         required: true
   *         description: Id del HorarioDia.
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/CrearVigenciaDto'
   *     responses:
   *       201:
   *         description: Vigencia creada correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResultCreate'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  CreateVigencia: '/:id/dias/:diaId/vigencias',

  /**
   * @swagger
   * /horarios/vigencias/{vigenciaId}:
   *   patch:
   *     tags:
   *       - Horarios
   *     summary: Actualiza una vigencia
   *     parameters:
   *       - in: path
   *         name: vigenciaId
   *         required: true
   *         description: Id de la vigencia (VigenciaId).
   *         schema:
   *           type: integer
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/ActualizarVigenciaDto'
   *     responses:
   *       200:
   *         description: Vigencia actualizada correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  UpdateVigencia: '/vigencias/:vigenciaId',

  /**
   * @swagger
   * /horarios/vigencias/{vigenciaId}:
   *   delete:
   *     tags:
   *       - Horarios
   *     summary: Elimina una vigencia
   *     description: Soft-delete de la vigencia.
   *     parameters:
   *       - in: path
   *         name: vigenciaId
   *         required: true
   *         description: Id de la vigencia (VigenciaId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Vigencia eliminada correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  DeleteVigencia: '/vigencias/:vigenciaId',

  /**
   * @swagger
   * /horarios/{id}/usuarios-batch:
   *   post:
   *     tags:
   *       - Horarios
   *     summary: Asigna usuarios a un horario
   *     description: Asigna en lote usuarios al horario validando que pertenezcan al area del horario.
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario (HorarioId).
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
   * /horarios/{id}/usuarios/{usuarioId}:
   *   delete:
   *     tags:
   *       - Horarios
   *     summary: Desasigna un usuario de un horario
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario (HorarioId).
   *         schema:
   *           type: integer
   *       - in: path
   *         name: usuarioId
   *         required: true
   *         description: Id del usuario (UsuarioId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Usuario desasignado correctamente.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/OperationResult'
   *       400:
   *         description: Datos inválidos.
   *       500:
   *         description: Error interno del servidor.
   */
  DesasignarUsuario: '/:id/usuarios/:usuarioId',

  /**
   * @swagger
   * /horarios/{id}/usuarios:
   *   get:
   *     tags:
   *       - Horarios
   *     summary: Lista usuarios asignados al horario
   *     parameters:
   *       - in: path
   *         name: id
   *         required: true
   *         description: Id del horario (HorarioId).
   *         schema:
   *           type: integer
   *     responses:
   *       200:
   *         description: Lista de usuarios asignados.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/UsuarioHorario'
   *       500:
   *         description: Error interno del servidor.
   */
  GetUsuarios: '/:id/usuarios',
};

export default HorarioPath;
