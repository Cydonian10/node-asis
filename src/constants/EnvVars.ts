/**
 * Environments variables declared here.
 */
import pkg from '../../package.json';

const normalizeBase = (p?: string) => {
  if (!p) return '/';
  return '/' + p.replace(/^\/+/, '').replace(/\/+$/, '');
};
export default {
  NodeEnv: process.env.NODE_ENV ?? '',
  Port: process.env.PORT ?? 0,
  Api: {
    Title: process.env.API_TITLE ?? 'API STANDART',
    Route: normalizeBase(process.env.ROUTE_BASE_API),
    version: pkg.version ?? '0.0.0.0',
    Host: process.env.HOST ?? 'localhost',
    Port: process.env.PORT ?? 3000,
    Cors: process.env.CORS_ORIGINS ?? '[*]',
    Security: process.env.SECURITY ?? 'off',
  },
  Kafka: {
    Id: process.env.KAFKA_CLIENT_ID ?? '',
    Brokers: process.env.KAFKA_BROKERS?.split(',') ?? [],
    auto: process.env.KAFKA_AUTO_CREATE_TOPICS ?? false,
    group_usuario: {
      id: process.env.KAFKA_GROUP_ID ?? '',
      creado: process.env.KAFKA_TOPIC_USUARIO_CREADO ?? '',
      actualizado: process.env.KAFKA_TOPIC_USUARIO_ACTUALIZADO ?? '',
      removido: process.env.KAFKA_TOPIC_USUARIO_REMOVIDO ?? '',
      error: process.env.KAFKA_TOPIC_USUARIO_ERROR ?? '',
    },
    topic: {
      aptitud: process.env.KAFKA_TOPIC_APTITUD ?? '',
    },
  },
  Database: {
    User: process.env.DB_USER ?? '',
    Password: process.env.DB_PASSWORD ?? '',
    Server: process.env.DB_SERVER ?? '',
    Port: Number(process.env.DB_PORT ?? 5432),
    Name: process.env.DB_NAME ?? '',
    Type: process.env.DB_TYPE ?? 'mock',
    Ssl: process.env.DB_SSL ?? false,
  },
  CookieProps: {
    Key: 'ExpressGeneratorTs',
    Secret: process.env.COOKIE_SECRET ?? '',
    // Casing to match express cookie options
    Options: {
      httpOnly: true,
      signed: true,
      path: process.env.COOKIE_PATH ?? '',
      maxAge: Number(process.env.COOKIE_EXP ?? 0),
      domain: process.env.COOKIE_DOMAIN ?? '',
      secure: process.env.SECURE_COOKIE === 'true',
    },
  },
  Jwt: {
    Secret: process.env.JWT_SECRET ?? '',
    Exp: process.env.COOKIE_EXP ?? '', // exp at the same time as the cookie
  },
} as const;
