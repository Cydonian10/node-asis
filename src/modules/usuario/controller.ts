import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';
import { Request, Response } from 'express';
import { UsuarioService } from './service.js';



const remove = async (req: Request, res: Response) => {
  const id = +req.params.id
  if (!id) {
    return res
      .status(HttpStatusCodes.BAD_REQUEST)
      .json({ message: 'El id debe ser un número válido' });
  }

  const result = await UsuarioService.remove(+id);
  return res.status(HttpStatusCodes.OK).json(result)
};

export default {
  remove,
};
