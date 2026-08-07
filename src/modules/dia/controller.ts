import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { Request, Response } from 'express';
import { DiaService } from './service.js';

const getAll = async (_req: Request, res: Response) => {
  const items = await DiaService.getAll();
  return res.status(HttpStatusCodes.OK).json(items);
};

export default {
  getAll,
};
