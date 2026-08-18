import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { Request, Response } from 'express';
import { HorarioService } from './service.js';
import { formatZodError } from '@src/util/zod-util.js';
import { CrearHorarioSchema } from './validations/crear-horario.validation.js';
import { ActualizarHorarioSchema } from './validations/actualizar-horario.validation.js';
import { CrearDiaSchema } from './validations/crear-dia.validation.js';
import { ActualizarDiaSchema } from './validations/actualizar-dia.validation.js';
import { CrearTurnoSchema } from './validations/crear-turno.validation.js';
import { ActualizarTurnoSchema } from './validations/actualizar-turno.validation.js';
import { CrearDiaConectadoSchema } from './validations/crear-dia-conectado.validation.js';
import { AsignarUsuariosSchema } from './validations/asignar-usuarios.validation.js';

const getAll = async (req: Request, res: Response) => {
  const areaId =
    req.query.areaId === undefined ? undefined : Number(req.query.areaId);
  const busqueda = req.query.busqueda as string | undefined;

  const items = await HorarioService.getAll(areaId, busqueda);
  return res.status(HttpStatusCodes.OK).json(items);
};

const getById = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const item = await HorarioService.getById(id);
  if (!item) {
    return res
      .status(HttpStatusCodes.NOT_FOUND)
      .json({ message: 'El horario no existe' });
  }
  return res.status(HttpStatusCodes.OK).json(item);
};

const getUsuarios = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const items = await HorarioService.getUsuarios(id);
  return res.status(HttpStatusCodes.OK).json(items);
};

const getMovimientos = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const items = await HorarioService.getMovimientos(id);
  return res.status(HttpStatusCodes.OK).json(items);
};

const create = async (req: Request, res: Response) => {
  const parsed = CrearHorarioSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await HorarioService.create(parsed.data);
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const update = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = ActualizarHorarioSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await HorarioService.update(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const remove = async (req: Request, res: Response) => {
  const id = +req.params.id;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const result = await HorarioService.remove(id);
  return res.status(HttpStatusCodes.OK).json(result);
};

const createDia = async (req: Request, res: Response) => {
  const horarioId = +req.params.id;
  if (!horarioId) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = CrearDiaSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await HorarioService.createDia(horarioId, parsed.data);
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const updateDia = async (req: Request, res: Response) => {
  const id = +req.params.diaId;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = ActualizarDiaSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await HorarioService.updateDia(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const removeDia = async (req: Request, res: Response) => {
  const id = +req.params.diaId;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const result = await HorarioService.removeDia(id);
  return res.status(HttpStatusCodes.OK).json(result);
};

const createTurno = async (req: Request, res: Response) => {
  const horarioDiaId = +req.params.diaId;
  if (!horarioDiaId) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = CrearTurnoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await HorarioService.createTurno(horarioDiaId, parsed.data);
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const updateTurno = async (req: Request, res: Response) => {
  const id = +req.params.turnoId;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = ActualizarTurnoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await HorarioService.updateTurno(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const removeTurno = async (req: Request, res: Response) => {
  const id = +req.params.turnoId;
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const result = await HorarioService.removeTurno(id);
  return res.status(HttpStatusCodes.OK).json(result);
};

const getTurnoDiaConectado = async (req: Request, res: Response) => {
  const turnoId = +req.params.turnoId;
  if (!turnoId) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const items = await HorarioService.getTurnoDiaConectado(turnoId);
  return res.status(HttpStatusCodes.OK).json(items);
};

const createTurnoDiaConectado = async (req: Request, res: Response) => {
  const turnoId = +req.params.turnoId;
  if (!turnoId) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const parsed = CrearDiaConectadoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await HorarioService.createTurnoDiaConectado(
    turnoId,
    parsed.data,
  );
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const removeTurnoDiaConectado = async (req: Request, res: Response) => {
  const salidaTurnoDiaId = +req.params.salidaTurnoDiaId;
  if (!salidaTurnoDiaId) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const result = await HorarioService.removeTurnoDiaConectado(salidaTurnoDiaId);
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

  const result = await HorarioService.asignarUsuarios(id, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const desasignarUsuario = async (req: Request, res: Response) => {
  const id = +req.params.id;
  const usuarioId = +req.params.usuarioId;
  if (!id || !usuarioId) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id y el usuarioId deben ser números válidos' });
  }

  const result = await HorarioService.desasignarUsuario(id, usuarioId);
  return res.status(HttpStatusCodes.OK).json(result);
};

export default {
  getAll,
  getById,
  getUsuarios,
  getMovimientos,
  create,
  update,
  remove,
  createDia,
  updateDia,
  removeDia,
  createTurno,
  updateTurno,
  removeTurno,
  getTurnoDiaConectado,
  createTurnoDiaConectado,
  removeTurnoDiaConectado,
  asignarUsuarios,
  desasignarUsuario,
};
