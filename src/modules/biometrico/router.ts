import { Router } from 'express';

import BiometricoPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(BiometricoPath.GetAll, Controller.getAll);
router.get(BiometricoPath.GetById, Controller.getById);
router.post(BiometricoPath.Create, Controller.create);
router.put(BiometricoPath.Update, Controller.update);
router.delete(BiometricoPath.Delete, Controller.remove);

export default router;
