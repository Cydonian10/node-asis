import { Router } from 'express';

import UsuarioPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.delete(UsuarioPath.Delete, Controller.remove);

export default router;
