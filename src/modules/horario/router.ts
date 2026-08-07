import { Router } from 'express';

import HorarioPath from './paths.js';
import Controller from './controller.js';

const router = Router();

router.get(HorarioPath.GetAll, Controller.getAll);
router.post(HorarioPath.Create, Controller.create);
router.get(HorarioPath.GetById, Controller.getById);
router.patch(HorarioPath.Update, Controller.update);
router.delete(HorarioPath.Delete, Controller.remove);

router.post(HorarioPath.CreateDia, Controller.createDia);
router.patch(HorarioPath.UpdateDia, Controller.updateDia);
router.delete(HorarioPath.DeleteDia, Controller.removeDia);

router.post(HorarioPath.CreateTurno, Controller.createTurno);
router.patch(HorarioPath.UpdateTurno, Controller.updateTurno);
router.delete(HorarioPath.DeleteTurno, Controller.removeTurno);

router.post(
  HorarioPath.CreateTurnoDiaConectado,
  Controller.createTurnoDiaConectado,
);
router.get(
  HorarioPath.GetTurnoDiaConectado,
  Controller.getTurnoDiaConectado,
);

router.post(HorarioPath.CreateVigencia, Controller.createVigencia);
router.patch(HorarioPath.UpdateVigencia, Controller.updateVigencia);
router.delete(HorarioPath.DeleteVigencia, Controller.removeVigencia);

router.post(HorarioPath.AsignarUsuarios, Controller.asignarUsuarios);
router.delete(HorarioPath.DesasignarUsuario, Controller.desasignarUsuario);
router.get(HorarioPath.GetUsuarios, Controller.getUsuarios);

export default router;
