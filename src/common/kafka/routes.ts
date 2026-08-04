import { z } from 'zod';
import EnvVars from '@src/constants/EnvVars.js';
import {
  handleUsuarioCreado,
  handleUsuarioRemove,
  handleUsuarioUpdate,
} from './handlers.js';

// Kafka deshabilitado: el módulo Usuario ya no gestiona RolUsuario.
// El schema del topic "creado" se deja con la forma del nuevo payload de migración.
const UsuarioCreadoKafkaSchema = z
  .object({
    syncUsuarioId: z.number().int().positive().optional(),
  })
  .strict();

const UsuarioUpdateKafkaSchema = z
  .object({
    id: z.number().int().positive(),
    rolId: z.number().int().positive(),
  })
  .strict();

const UsuarioDeleteKafkaSchema = z
  .object({
    id: z.number().int().positive(),
  })
  .strict();

const gUsuario = EnvVars.Kafka.group_usuario;
export const kafkaRoutes = {
  [gUsuario.id]: {
    [gUsuario.creado]: {
      schema: UsuarioCreadoKafkaSchema,
      handler: handleUsuarioCreado,
      error: gUsuario.error,
    },
    [gUsuario.actualizado]: {
      schema: UsuarioUpdateKafkaSchema,
      handler: handleUsuarioUpdate,
      error: gUsuario.error,
    },
    [gUsuario.removido]: {
      schema: UsuarioDeleteKafkaSchema,
      handler: handleUsuarioRemove,
      error: gUsuario.error,
    },
  },
};
