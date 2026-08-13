import { Router } from 'express';

import AreaPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(AreaPath.GetAll, Controller.getAll);
router.get(AreaPath.GetById, Controller.getById);
router.post(AreaPath.Create, Controller.create);
router.patch(AreaPath.Update, Controller.update);
router.delete(AreaPath.Delete, Controller.remove);
router.post(AreaPath.AsignarUsuarios, Controller.asignarUsuarios);
router.get(AreaPath.GetUsuarios, Controller.getUsuarios);

export default router;
