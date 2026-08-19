import { Request, Response } from 'express';
import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { formatZodError } from '@src/util/zod-util.js';
import { TurnoModificadoService } from './service.js';
import { CrearTurnoModificadoSchema } from './validations/crear-turno-modificado.validation.js';
import { ActualizarTurnoModificadoSchema } from './validations/actualizar-turno-modificado.validation.js';
import { TurnoModificadoFilterSchema } from './validations/turno-modificado-filter.validation.js';

const parsePositiveId = (
  value: string | undefined,
  name: string,
  res: Response,
): number | null => {
  const id = Number(value);
  if (!Number.isInteger(id) || id <= 0) {
    res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: `${name} debe ser un número válido`,
    });
    return null;
  }
  return id;
};

const parseQuery = (req: Request) => {
  const query = req.query as Record<string, unknown>;
  const toNumber = (value: unknown) =>
    value === undefined ? undefined : Number(value);
  return {
    fechaDesde: query.fechaDesde as string | undefined,
    fechaHasta: query.fechaHasta as string | undefined,
    usuarioId: toNumber(query.usuarioId),
  };
};

const getAll = async (req: Request, res: Response) => {
  const turnoId = parsePositiveId(req.params.turnoId, 'turnoId', res);
  if (turnoId === null) return;

  const parsed = TurnoModificadoFilterSchema.safeParse(parseQuery(req));
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Filtros inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await TurnoModificadoService.getAll(turnoId, parsed.data);
  return res.status(HttpStatusCodes.OK).json(result);
};

const create = async (req: Request, res: Response) => {
  const turnoId = parsePositiveId(req.params.turnoId, 'turnoId', res);
  if (turnoId === null) return;

  const parsed = CrearTurnoModificadoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await TurnoModificadoService.create(turnoId, parsed.data);
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const getById = async (req: Request, res: Response) => {
  const turnoId = parsePositiveId(req.params.turnoId, 'turnoId', res);
  if (turnoId === null) return;
  const turnoModificadoId = parsePositiveId(
    req.params.turnoModificadoId,
    'turnoModificadoId',
    res,
  );
  if (turnoModificadoId === null) return;

  const result = await TurnoModificadoService.getById(
    turnoId,
    turnoModificadoId,
  );
  if (!result) {
    return res.status(HttpStatusCodes.NOT_FOUND).json({
      message: 'La modificación de turno no existe',
    });
  }
  return res.status(HttpStatusCodes.OK).json(result);
};

const update = async (req: Request, res: Response) => {
  const turnoId = parsePositiveId(req.params.turnoId, 'turnoId', res);
  if (turnoId === null) return;
  const turnoModificadoId = parsePositiveId(
    req.params.turnoModificadoId,
    'turnoModificadoId',
    res,
  );
  if (turnoModificadoId === null) return;

  const parsed = ActualizarTurnoModificadoSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(HttpStatusCodes.BAD_REQUEST).json({
      message: 'Datos inválidos',
      errors: formatZodError(parsed.error),
    });
  }

  const result = await TurnoModificadoService.update(
    turnoId,
    turnoModificadoId,
    parsed.data,
  );
  return res
    .status(
      result.State === 1 ? HttpStatusCodes.OK : HttpStatusCodes.BAD_REQUEST,
    )
    .json(result);
};

const remove = async (req: Request, res: Response) => {
  const turnoId = parsePositiveId(req.params.turnoId, 'turnoId', res);
  if (turnoId === null) return;
  const turnoModificadoId = parsePositiveId(
    req.params.turnoModificadoId,
    'turnoModificadoId',
    res,
  );
  if (turnoModificadoId === null) return;

  const result = await TurnoModificadoService.remove(
    turnoId,
    turnoModificadoId,
  );
  return res
    .status(
      result.State === 1 ? HttpStatusCodes.OK : HttpStatusCodes.BAD_REQUEST,
    )
    .json(result);
};

export default { getAll, create, getById, update, remove };
