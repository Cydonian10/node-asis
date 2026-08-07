import { Router } from 'express';

import AsistenciaPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.post(AsistenciaPath.ProcesarMarcaciones, Controller.procesarMarcaciones);
router.post(
  AsistenciaPath.ReprocesarAsistencias,
  Controller.reprocesarAsistencias,
);

export default router;
