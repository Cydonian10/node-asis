import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { Request, Response } from 'express';
import { UnidadService } from './service.js';
import { formatZodError } from '@src/util/zod-util.js';
import { ActualizarUnidadSchema } from './validations/actualizar-unidad.validation.js';
import { MigrarSyncUnidadSchema } from './validations/migrar-sync-unidad.validation.js';

const getAll = async (req: Request, res: Response) => {
  const busqueda = req.query.busqueda as string | undefined;

  const items = await UnidadService.getAllMigradas(busqueda);
  return res.status(HttpStatusCodes.OK).json(items);
};

const getAllSync = async (req: Request, res: Response) => {
  const items = await UnidadService.getAllSync();
  return res.status(HttpStatusCodes.OK).json(items);
};

const update = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = ActualizarUnidadSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await UnidadService.updateHoras(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const remove = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const result = await UnidadService.remove(id);
  return res.status(HttpStatusCodes.OK).json(result);
};

const migrar = async (req: Request, res: Response) => {
  const parsed = MigrarSyncUnidadSchema.safeParse(req.body ?? {});
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await UnidadService.migrar(parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

export default {
  getAll,
  getAllSync,
  update,
  remove,
  migrar,
};
