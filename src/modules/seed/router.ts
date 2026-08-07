import { Router } from 'express';

import SeedPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.post(SeedPath.Create, Controller.seedDatos);
router.delete(SeedPath.Delete, Controller.deleteSeedDatos);

export default router;
