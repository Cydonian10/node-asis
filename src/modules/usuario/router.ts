import { Router } from 'express';

import UsuarioPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(UsuarioPath.GetAll, Controller.getAllMigrados);
router.get(UsuarioPath.GetAllSync, Controller.getAllSync);
router.post(UsuarioPath.CreateSync, Controller.createSyncUsuario);
router.get(UsuarioPath.GetById, Controller.getById);
router.patch(UsuarioPath.Update, Controller.update);

export default router;
