import { Request, Response } from 'express';
import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { formatZodError } from '@src/util/zod-util.js';
import { BiometricoService } from './service.js';
import { CrearBiometricoSchema } from './validations/crear-biometrico.validation.js';
import { ActualizarBiometricoSchema } from './validations/actualizar-biometrico.validation.js';

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
  const items = await BiometricoService.getAll();
  return res.status(HttpStatusCodes.OK).json(items);
};

const getById = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const item = await BiometricoService.getById(id);
  if (!item) {
    return res.status(HttpStatusCodes.NOT_FOUND).json({
      message: 'El biometrico no fue encontrado',
    });
  }
  return res.status(HttpStatusCodes.OK).json(item);
};

const create = async (req: Request, res: Response) => {
  const parsed = CrearBiometricoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await BiometricoService.create(parsed.data);
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const update = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const parsed = ActualizarBiometricoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await BiometricoService.update(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const remove = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const result = await BiometricoService.remove(id);
  return res.status(HttpStatusCodes.OK).json(result);
};

export default { getAll, getById, create, update, remove };
