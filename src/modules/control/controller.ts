import { Request, Response } from 'express';
import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { formatZodError } from '@src/util/zod-util.js';
import { ControlService } from './service.js';
import { CrearControlSchema } from './validations/crear-control.validation.js';
import { ActualizarControlSchema } from './validations/actualizar-control.validation.js';
import { AsignarControlAreaSchema } from './validations/asignar-control-area.validation.js';
import { AsignarControlUnidadSchema } from './validations/asignar-control-unidad.validation.js';
import { AsignarControlUsuarioSchema } from './validations/asignar-control-usuario.validation.js';
import { DesasignarControlAreaSchema } from './validations/desasignar-control-area.validation.js';
import { DesasignarControlUnidadSchema } from './validations/desasignar-control-unidad.validation.js';
import { DesasignarControlUsuarioSchema } from './validations/desasignar-control-usuario.validation.js';

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
  const items = await ControlService.getAll();
  return res.status(HttpStatusCodes.OK).json(items);
};

const create = async (req: Request, res: Response) => {
  const parsed = CrearControlSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await ControlService.create(parsed.data);
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const update = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const parsed = ActualizarControlSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await ControlService.update(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const remove = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const result = await ControlService.remove(id);
  return res.status(HttpStatusCodes.OK).json(result);
};

const assignArea = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const parsed = AsignarControlAreaSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await ControlService.assignArea(id, parsed.data.areaId);
  if (!result.ok) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json(result.result);
  }
  return res.status(HttpStatusCodes.OK).json(result.control);
};

const assignUnidad = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const parsed = AsignarControlUnidadSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await ControlService.assignUnidad(id, parsed.data.unidadId);
  if (!result.ok) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json(result.result);
  }
  return res.status(HttpStatusCodes.OK).json(result.control);
};

const assignUsuario = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const parsed = AsignarControlUsuarioSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await ControlService.assignUsuario(id, parsed.data.usuarioId);
  if (!result.ok) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json(result.result);
  }
  return res.status(HttpStatusCodes.OK).json(result.control);
};

const unassignArea = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const parsed = DesasignarControlAreaSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await ControlService.unassignArea(id, parsed.data.areaId);
  if (!result.ok) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json(result.result);
  }
  return res.status(HttpStatusCodes.OK).json(result.control);
};

const unassignUnidad = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const parsed = DesasignarControlUnidadSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await ControlService.unassignUnidad(id, parsed.data.unidadId);
  if (!result.ok) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json(result.result);
  }
  return res.status(HttpStatusCodes.OK).json(result.control);
};

const unassignUsuario = async (req: Request, res: Response) => {
  const id = parseId(req, res);
  if (id === null) return;

  const parsed = DesasignarControlUsuarioSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await ControlService.unassignUsuario(
    id,
    parsed.data.usuarioId,
  );
  if (!result.ok) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json(result.result);
  }
  return res.status(HttpStatusCodes.OK).json(result.control);
};

export default {
  getAll,
  create,
  update,
  remove,
  assignArea,
  assignUnidad,
  assignUsuario,
  unassignArea,
  unassignUnidad,
  unassignUsuario,
};
