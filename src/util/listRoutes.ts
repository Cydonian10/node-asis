import { Router, Request, Response, Application } from 'express';
import listEndpoints from 'express-list-endpoints';
import EnvVars from '../constants/EnvVars.js';
import logger from '@src/common/logger.js';

interface Endpoint {
  path: string;
  methods: string[];
}

const router = Router();
const port = EnvVars.Api.Port;
const route = EnvVars.Api.Route;
const host = EnvVars.Api.Host;
logger.info(
  `Debug routes available at http://${host}:${port}${route}/debug/routes`,
);

/**
 * @swagger
 * /debug/routes:
 *  get:
 *    tags:
 *      - Debug
 *    summary: Ruta para listar todas las rutas disponibles
 *    responses:
 *      200:
 *        description: Lista las rutas disponibles
 *        content:
 *          aplication/json:
 *            schema:
 *              type: object
 *              properties:
 *                routes:
 *                  type: array
 *                  items:
 *                    $ref: '#/components/schemas/Route'
 */

/**
 * @swagger
 * components:
 *  schemas:
 *    Route:
 *      type: object
 *      description: Un objeto que describe una ruta de API.
 *      properties:
 *        status:
 *          type: string
 *        routes:
 *          type: array
 *          items:
 *            $ref: '#/components/schemas/RouteItem'
 *    RouteItem:
 *      type: object
 *      properties:
 *        path:
 *          type: string
 *        methods:
 *          type: array
 *          items:
 *            type: string
 *        middlewares:
 *          type: array
 *          items:
 *            type: string
 */
router.get('/debug/routes', (req: Request, res: Response) => {
  const app = req.app as Application;

  const routes = listEndpoints(app) as Endpoint[];

  res.json({ status: 'success', routes });
});

export default router;
