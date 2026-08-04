import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';
import { IUser } from '@src/common/types/user.js';
import { authService } from '@src/common/auth.service.js';

interface AuthenticatedRequest extends Request {
  user?: IUser;
}

const authenticateToken = (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
) => {
  // Permitir acceso sin autenticación a la documentación de Swagger
  if (req.path.startsWith('/api-docs') || req.path.startsWith('/swagger')) {
    return next();
  }

  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) {
    return res
      .status(401)
      .json({ message: 'Token de autenticación no proporcionado' });
  }

  try {
    const user = jwt.verify(token, String(process.env.JWT_SECRET)) as IUser;
    authService.userAuth = user;
    return next();
  } catch {
    return res.status(403).json({ message: 'Token inválido' });
  }
};

export default authenticateToken;
