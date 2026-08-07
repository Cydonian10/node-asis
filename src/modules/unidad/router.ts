import { Router } from 'express';

import UnidadPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(UnidadPath.GetAll, Controller.getAll);
router.get(UnidadPath.GetAllSync, Controller.getAllSync);
router.patch(UnidadPath.Update, Controller.update);
router.delete(UnidadPath.Delete, Controller.remove);
router.post(UnidadPath.Migrar, Controller.migrar);
router.post(UnidadPath.CrearAreas, Controller.crearAreas);
router.get(UnidadPath.GetUsuarios, Controller.getUsuarios);

export default router;
