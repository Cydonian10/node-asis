import { Request, Response } from 'express';
import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { formatZodError } from '@src/util/zod-util.js';
import { MotivoService } from './service.js';
import { CrearMotivoSchema } from './validations/crear-motivo.validation.js';
import { ActualizarMotivoSchema } from './validations/actualizar-motivo.validation.js';

const parseId = (req: Request, res: Response): number | null => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'El id debe ser un número válido',
    });
    return null;
  }
  return id;
};

const getAll = async (_req: Request, res: Response) => {
  const items = await MotivoService.getAll();
  return res.status(HttpStatusCodes.OK).json(items);
};

const getById = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const item = await MotivoService.getById(id);
  if (!item) {
    return res.status(HttpStatusCodes.NOT_FOUND).json({
      message: 'El motivo no fue encontrado',
    });
  }
  return res.status(HttpStatusCodes.OK).json(item);
};

const create = async (req: Request, res: Response) => {
  const parsed = CrearMotivoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await MotivoService.create(parsed.data);
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const update = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const parsed = ActualizarMotivoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await MotivoService.update(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const remove = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const result = await MotivoService.remove(id);
  return res.status(HttpStatusCodes.OK).json(result);
};

export default { getAll, getById, create, update, remove };
