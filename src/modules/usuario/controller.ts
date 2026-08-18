import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { Request, Response } from 'express';
import { UsuarioService } from './service.js';
import { formatZodError } from '@src/util/zod-util.js';
import { ActualizarUsuarioSchema } from './validations/actualizar-usuario.validation.js';
import { CrearSyncUsuarioSchema } from './validations/crear-sync-usuario.validation.js';

const getAllMigrados = async (req: Request, res: Response) => {
  const activo =
    req.query.activo === undefined ? undefined : req.query.activo === 'true';
  const tipo = req.query.tipo as string | undefined;
  const busqueda = req.query.busqueda as string | undefined;
  const areaId =
    req.query.areaId === undefined ? undefined : Number(req.query.areaId);
  const unidadId =
    req.query.unidadId === undefined ? undefined : Number(req.query.unidadId);

  const items = await UsuarioService.getAllMigrados(
    activo,
    tipo,
    busqueda,
    areaId,
    unidadId,
  );
  return res.status(HttpStatusCodes.OK).json(items);
};

const getById = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const usuarios = await UsuarioService.getById(id);
  if (!usuarios.length) {
    return res
      .status(HttpStatusCodes.NOT_FOUND)
      .json({ message: 'El usuario no fue encontrado' });
  }
  return res.status(HttpStatusCodes.OK).json(usuarios);
};

const getAllSync = async (req: Request, res: Response) => {
  const items = await UsuarioService.getAllSync();
  return res.status(HttpStatusCodes.OK).json(items);
};

const createSyncUsuario = async (req: Request, res: Response) => {
  const parsed = CrearSyncUsuarioSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await UsuarioService.createSyncUsuario(parsed.data);
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const getHorarios = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const items = await UsuarioService.getHorarios(id);
  return res.status(HttpStatusCodes.OK).json(items);
};

const update = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = ActualizarUsuarioSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await UsuarioService.update(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

export default {
  getAllMigrados,
  getById,
  getAllSync,
  createSyncUsuario,
  update,
  getHorarios,
};
