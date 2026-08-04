import { UsuarioService } from '@src/modules/usuario/service.js';
import logger from '../logger.js';

// Kafka deshabilitado: el módulo Usuario ya no gestiona RolUsuario.
// Pendiente de adaptar cuando se reactive Kafka (ver spec 01).
export async function handleUsuarioCreado(payload: unknown): Promise<void> {
  try {
    // const result = await UsuarioService.create(payload as AsignarUsuarioDto);
    // logger.info(`[handleUsuarioCreado] Insert result: ${JSON.stringify(result)}`);
    void payload;
    void UsuarioService;
    void logger;
  } catch (err) {
    const msg =
      err instanceof Error
        ? `[handleUsuarioCreado] ${err.message}\n${err.stack}`
        : `[handleUsuarioCreado] Error inesperado: ${JSON.stringify(err)}`;

    logger.err(msg);
  }
}

export async function handleUsuarioUpdate(payload: unknown): Promise<void> {
  try {
    // const result = await UsuarioService.update(payload.id, { rolId: payload.rolId });
    // logger.info(`[handleUsuarioUpdate] Update result: ${JSON.stringify(result)}`);
    void payload;
  } catch (error) {
    const msg =
      error instanceof Error
        ? `[handleUsuarioUpdate] ${error.message}\n${error.stack}`
        : `[handleUsuarioUpdate] Error inesperado: ${JSON.stringify(error)}`;
    logger.err(msg);
  }
}

export async function handleUsuarioRemove(payload: unknown): Promise<void> {
  try {
    // const result = await UsuarioService.remove(payload.id);
    // logger.info(`[handleUsuarioRemove] Remove result: ${JSON.stringify(result)}`);
    void payload;
  } catch (error) {
    const msg =
      error instanceof Error
        ? `[handleUsuarioRemove] ${error.message}\n${error.stack}`
        : `[handleUsuarioRemove] Error inesperado: ${JSON.stringify(error)}`;
    logger.err(msg);
  }
}
