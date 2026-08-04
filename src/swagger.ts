import swaggerJsDoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';
import { Express } from 'express';
import dotenv from 'dotenv';
import logger from '@src/common/logger.js';
import EnvVars from './constants/EnvVars.js';

dotenv.config();

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: EnvVars.Api.Title,
      version: EnvVars.Api.version,
      description: 'Documentación de la API con Swagger',
    },
    servers: [
      {
        url:
          `http://${EnvVars.Api.Host}:` +
          `${EnvVars.Api.Port}${EnvVars.Api.Route}`,
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ['./src/modules/**/*.ts', './src/common/types/*.ts', './src/util/*.ts'],
};

const swaggerSpec = swaggerJsDoc(options);

const swaggerDocs = (app: Express, port: number) => {
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
  app.get('/api-docs.json', (_req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(swaggerSpec);
  });
  logger.info(`Swagger docs available at http://localhost:${port}/api-docs`);
};

export default swaggerDocs;
