import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { Request, Response } from 'express';
import { RolService } from './service.js';
import { formatZodError } from '@src/util/zod-util.js';
import { CrearRolUnidadSchema } from './validations/crear-rol-unidad.validation.js';
import { AsignarUsuariosSchema } from './validations/asignar-usuarios.validation.js';

const getRoles = async (req: Request, res: Response) => {
  const items = await RolService.getRoles();
  return res.status(HttpStatusCodes.OK).json(items);
};

const createRolUnidad = async (req: Request, res: Response) => {
  const unidadId = +req.params.unidadId;
  if (!unidadId) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = CrearRolUnidadSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await RolService.createRolUnidad(unidadId, parsed.data);
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const getRolUnidadByUnidad = async (req: Request, res: Response) => {
  const unidadId = +req.params.unidadId;
  if (!unidadId) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const items = await RolService.getRolUnidadByUnidad(unidadId);
  return res.status(HttpStatusCodes.OK).json(items);
};

const removeRolUnidad = async (req: Request, res: Response) => {
  const rolUnidadId = +req.params.rolUnidadId;
  if (!rolUnidadId) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const result = await RolService.removeRolUnidad(rolUnidadId);
  return res.status(HttpStatusCodes.OK).json(result);
};

const asignarUsuarios = async (req: Request, res: Response) => {
  const rolUnidadId = +req.params.rolUnidadId;
  if (!rolUnidadId) {
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

  const result = await RolService.asignarUsuarios(rolUnidadId, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const getUsuarios = async (req: Request, res: Response) => {
  const rolUnidadId = +req.params.rolUnidadId;
  if (!rolUnidadId) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const items = await RolService.getUsuarios(rolUnidadId);
  return res.status(HttpStatusCodes.OK).json(items);
};

export default {
  getRoles,
  createRolUnidad,
  getRolUnidadByUnidad,
  removeRolUnidad,
  asignarUsuarios,
  getUsuarios,
};
