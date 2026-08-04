import { Router } from 'express';
import { registerRoutes } from './register.js';
import listRoutes from '../util/listRoutes.js';

const apiRouter = Router();

// Registro centralizado de rutas
registerRoutes(apiRouter);

// Registrar la ruta de depuración
apiRouter.use(listRoutes);

export default apiRouter;
