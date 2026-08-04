import logger from '../logger.js';

// Kafka deshabilitado: el módulo Usuario ya no gestiona RolUsuario.
// Pendiente de adaptar cuando se reactive Kafka (ver spec 01).
export function handleUsuarioCreado(payload: unknown): Promise<void> {
  void payload;
  void logger;
  return Promise.resolve();
}

export function handleUsuarioUpdate(payload: unknown): Promise<void> {
  void payload;
  return Promise.resolve();
}

export function handleUsuarioRemove(payload: unknown): Promise<void> {
  void payload;
  return Promise.resolve();
}
