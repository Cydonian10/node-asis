import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { Request, Response } from 'express';
import { SeedService } from './service.js';

const seedDatos = async (_req: Request, res: Response) => {
  const result = await SeedService.seedDatos();
  return res.status(HttpStatusCodes.CREATED).json(result);
};

const deleteSeedDatos = async (_req: Request, res: Response) => {
  const result = await SeedService.deleteSeedDatos();
  return res.status(HttpStatusCodes.OK).json(result);
};

export default {
  seedDatos,
  deleteSeedDatos,
};
