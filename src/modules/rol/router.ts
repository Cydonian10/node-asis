import { Router } from 'express';

import RolPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(RolPath.GetRoles, Controller.getRoles);
router.post(RolPath.CreateRolUnidad, Controller.createRolUnidad);
router.get(RolPath.GetRolUnidadByUnidad, Controller.getRolUnidadByUnidad);
router.delete(RolPath.DeleteRolUnidad, Controller.removeRolUnidad);
router.post(RolPath.AsignarUsuarios, Controller.asignarUsuarios);
router.get(RolPath.GetUsuarios, Controller.getUsuarios);

export default router;
