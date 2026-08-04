import { z } from 'zod';
import EnvVars from '@src/constants/EnvVars.js';
import { AsignarUsuarioSchema } from '@src/modules/usuario/dto/usuario.dto.js';
import {
  handleUsuarioCreado,
  handleUsuarioRemove,
  handleUsuarioUpdate,
} from './handlers.js';

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
      schema: AsignarUsuarioSchema,
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
