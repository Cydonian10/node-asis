import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { Request, Response } from 'express';
import { UsuarioService } from './service.js';
import { formatZodError } from '@src/util/zod-util.js';
import { ActualizarActivoSchema } from './validations/actualizar-activo.validation.js';
import { MigrarSyncUsuarioSchema } from './validations/migrar-sync-usuario.validation.js';

const getAllMigrados = async (req: Request, res: Response) => {
  const activo =
    req.query.activo === undefined
      ? undefined
      : req.query.activo === 'true';
  const tipo = req.query.tipo as string | undefined;
  const busqueda = req.query.busqueda as string | undefined;

  const items = await UsuarioService.getAllMigrados(activo, tipo, busqueda);
  return res.status(HttpStatusCodes.OK).json(items);
};

const getAllSync = async (req: Request, res: Response) => {
  const items = await UsuarioService.getAllSync();
  return res.status(HttpStatusCodes.OK).json(items);
};

const updateActivo = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = ActualizarActivoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'Datos inválidos', errors: formatZodError(parsed.error) });
  }

  const result = await UsuarioService.updateActivo(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const migrar = async (req: Request, res: Response) => {
  const parsed = MigrarSyncUsuarioSchema.safeParse(req.body ?? {});
  if (!parsed.success) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'Datos inválidos', errors: formatZodError(parsed.error) });
  }

  const result = await UsuarioService.migrar(parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

export default {
  getAllMigrados,
  getAllSync,
  updateActivo,
  migrar,
};
