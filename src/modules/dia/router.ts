import { Router } from 'express';

import DiaPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(DiaPath.GetAll, Controller.getAll);

export default router;
