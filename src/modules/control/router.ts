import { Router } from 'express';

import ControlPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(ControlPath.GetAll, Controller.getAll);
router.post(ControlPath.Create, Controller.create);
router.put(ControlPath.Update, Controller.update);
router.delete(ControlPath.Delete, Controller.remove);

router.post(ControlPath.AssignArea, Controller.assignArea);
router.post(ControlPath.AssignUnidad, Controller.assignUnidad);
router.post(ControlPath.AssignUsuario, Controller.assignUsuario);

router.delete(ControlPath.UnassignArea, Controller.unassignArea);
router.delete(ControlPath.UnassignUnidad, Controller.unassignUnidad);
router.delete(ControlPath.UnassignUsuario, Controller.unassignUsuario);

export default router;
