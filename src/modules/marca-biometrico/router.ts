import { Router } from 'express';

import MarcaBiometricoPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(MarcaBiometricoPath.GetAll, Controller.getAll);
router.get(MarcaBiometricoPath.GetById, Controller.getById);
router.post(MarcaBiometricoPath.Create, Controller.create);
router.put(MarcaBiometricoPath.Update, Controller.update);
router.delete(MarcaBiometricoPath.Delete, Controller.remove);

export default router;
