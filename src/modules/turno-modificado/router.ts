import { Router } from 'express';
import TurnoModificadoPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(TurnoModificadoPath.GetAll, Controller.getAll);
router.post(TurnoModificadoPath.Create, Controller.create);
router.get(TurnoModificadoPath.GetOne, Controller.getById);
router.put(TurnoModificadoPath.Update, Controller.update);
router.delete(TurnoModificadoPath.Delete, Controller.remove);

export default router;
