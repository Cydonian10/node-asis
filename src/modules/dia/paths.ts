const DiaPath = {
  Base: '/dias',

  /**
   * @swagger
   * /dias:
   *   get:
   *     tags:
   *       - Dias
   *     summary: Lista el catalogo de dias
   *     description: Lista el catalogo de dias (7 filas fijas: Lunes..Domingo).
   *     responses:
   *       200:
   *         description: Lista de dias del catalogo.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/Dia'
   *       500:
   *         description: Error interno del servidor.
   */
  GetAll: '/',
};

export default DiaPath;
