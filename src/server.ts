/**
 * Setup express server.
 */

import cookieParser from 'cookie-parser';
import morgan from 'morgan';
import helmet from 'helmet';
import express, { Request, Response, NextFunction } from 'express';
import logger from '@src/common/logger.js';
import cors from 'cors';

import 'express-async-errors';

import BaseRouter from '@src/routes/index.js';

import EnvVars from '@src/constants/EnvVars.js';
import HttpStatusCodes from '@src/constants/HttpStatusCodes.js';

import { NodeEnvs } from '@src/constants/misc.js';
import { RouteError } from '@src/common/classes.js';
import { fileURLToPath } from 'url';
import authenticateToken from './middleware/authMiddleware.js';
import swaggerDocs from './swagger.js';
import path from 'path';

// **** Variables **** //

const app = express();

// Define __dirname and __filename in ES module scope
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const corsConfig = EnvVars.Api.Cors;
const allowedOrigins: string[] =
  typeof corsConfig === 'string' && corsConfig.trim() !== ''
    ? (JSON.parse(corsConfig) as string[])
    : ['*'];

app.use(
  cors({
    origin: allowedOrigins,
    credentials: true,
  }),
);

if (
  EnvVars.NodeEnv === 'production' ||
  (EnvVars.NodeEnv === 'development' && EnvVars.Api.Security === 'on')
) {
  app.use(authenticateToken);
}

// **** Setup **** //

// Basic middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser(EnvVars.CookieProps.Secret));

app.use(express.static(path.join(__dirname, '../templates')));

// Show routes called in console during development
if (EnvVars.NodeEnv === NodeEnvs.Dev.valueOf()) {
  app.use(morgan('dev'));
}

// Security
if (EnvVars.NodeEnv === NodeEnvs.Production.valueOf()) {
  app.use(helmet());
}

// Add APIs, must be after middleware
app.use(EnvVars.Api.Route, BaseRouter);

// Setup Swagger
swaggerDocs(app, +EnvVars.Port);

// Add error handler
app.use((err: Error, _: Request, res: Response, _next: NextFunction) => {
  if (EnvVars.NodeEnv !== NodeEnvs.Test.valueOf()) {
    logger.err(err, true);
  }
  let status = HttpStatusCodes.BAD_REQUEST;
  if (err instanceof RouteError) {
    status = err.status;
  }
  return res.status(status).json({ error: err.message });
});

// **** Export default **** //

export default app;
