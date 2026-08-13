import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { Request, Response } from 'express';
import { AreaService } from './service.js';
import { formatZodError } from '@src/util/zod-util.js';
import { CrearAreaSchema } from './validations/crear-area.validation.js';
import { ActualizarAreaSchema } from './validations/actualizar-area.validation.js';
import { AsignarUsuariosSchema } from './validations/asignar-usuarios.validation.js';

const getAll = async (req: Request, res: Response) => {
  const unidadId =
    req.query.unidadId === undefined ? undefined : Number(req.query.unidadId);
  const busqueda = req.query.busqueda as string | undefined;
  const tipo = req.query.tipo as string | undefined;

  const items = await AreaService.getAll(unidadId, busqueda, tipo);
  return res.status(HttpStatusCodes.OK).json(items);
};

const getById = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const area = await AreaService.getById(id);
  if (!area) {
    return res
      .status(HttpStatusCodes.NOT_FOUND)
      .json({ message: 'El área no fue encontrada' });
  }
  return res.status(HttpStatusCodes.OK).json(area);
};

const create = async (req: Request, res: Response) => {
  const parsed = CrearAreaSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await AreaService.create(parsed.data);
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const update = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = ActualizarAreaSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await AreaService.update(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const remove = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const result = await AreaService.remove(id);
  return res.status(HttpStatusCodes.OK).json(result);
};

const asignarUsuarios = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = AsignarUsuariosSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await AreaService.asignarUsuarios(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const getUsuarios = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const items = await AreaService.getUsuarios(id);
  return res.status(HttpStatusCodes.OK).json(items);
};

export default {
  getAll,
  getById,
  create,
  update,
  remove,
  asignarUsuarios,
  getUsuarios,
};
