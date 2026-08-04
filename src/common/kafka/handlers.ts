import { UsuarioService } from '@src/modules/usuario/service.js';
import logger from '../logger.js';
import { AsignarUsuarioDto } from '@src/modules/usuario/dto/usuario.dto.js';

export async function handleUsuarioCreado(
  payload: AsignarUsuarioDto,
): Promise<void> {
  try {
    const result = await UsuarioService.create(payload);
    logger.info(
      `[handleUsuarioCreado] Insert result: ${JSON.stringify(result)}`,
    );
  } catch (err) {
    const msg =
      err instanceof Error
        ? `[handleUsuarioCreado] ${err.message}\n${err.stack}`
        : `[handleUsuarioCreado] Error inesperado: ${JSON.stringify(err)}`;

    logger.err(msg);
  }
}

export async function handleUsuarioUpdate(payload: {
  id: number;
  rolId: number;
}): Promise<void> {
  try {
    const result = await UsuarioService.update(payload.id, {
      rolId: payload.rolId,
    });
    logger.info(
      `[handleUsuarioUpdate] Update result: ${JSON.stringify(result)}`,
    );
  } catch (error) {
    const msg =
      error instanceof Error
        ? `[handleUsuarioUpdate] ${error.message}\n${error.stack}`
        : `[handleUsuarioUpdate] Error inesperado: ${JSON.stringify(error)}`;
    logger.err(msg);
  }
}

export async function handleUsuarioRemove(payload: {
  id: number;
}): Promise<void> {
  try {
    const result = await UsuarioService.remove(payload.id);
    logger.info(
      `[handleUsuarioRemove] Remove result: ${JSON.stringify(result)}`,
    );
  } catch (error) {
    const msg =
      error instanceof Error
        ? `[handleUsuarioRemove] ${error.message}\n${error.stack}`
        : `[handleUsuarioRemove] Error inesperado: ${JSON.stringify(error)}`;
    logger.err(msg);
  }
}
