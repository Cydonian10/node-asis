import { Router } from 'express';
import MotivoPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(MotivoPath.GetAll, Controller.getAll);
router.get(MotivoPath.GetById, Controller.getById);
router.post(MotivoPath.Create, Controller.create);
router.put(MotivoPath.Update, Controller.update);
router.delete(MotivoPath.Delete, Controller.remove);

export default router;
