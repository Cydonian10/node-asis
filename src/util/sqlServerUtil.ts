import sql from 'mssql';
import { connectToDb } from '@src/config/db-sqlserver.js';

export type SPOutput = {
  State: number;
  Message: string;
  CodeError: number;
  Id?: number | null;
};

/**
 * Ejecuta varias operaciones usando la misma transaccion.
 * Si una operacion falla, se intenta deshacer todo el trabajo realizado.
 */
export async function runTransaction<T>(
  callback: (transaction: sql.Transaction) => Promise<T>,
): Promise<T> {
  const pool = await connectToDb();
  const transaction = new sql.Transaction(pool);
  await transaction.begin();

  try {
    const result = await callback(transaction);
    await transaction.commit();
    return result;
  } catch (error) {
    try {
      await transaction.rollback();
    } catch {
      // El error original es mas util que un fallo posterior durante rollback.
    }
    throw error;
  }
}

/**
 * Ejecuta un procedimiento de creacion y valida el estado devuelto por el SP.
 * Centralizar esta regla evita repetir la configuracion de outputs en cada repo.
 */
export async function executeCreate(
  transaction: sql.Transaction,
  procedureName: string,
  configure: (request: sql.Request) => void,
): Promise<SPOutput> {
  const request = new sql.Request(transaction);
  configure(request);
  request.output('State', sql.Int);
  request.output('Message', sql.VarChar(255));
  request.output('CodeError', sql.Int);

  const result = await request.execute(procedureName);
  const output = result.output as unknown as SPOutput;
  if (output.State !== 1) {
    throw new Error(`SP ${procedureName} fallo: ${output.Message}`);
  }
  return output;
}

/** Obtiene el Id generado por un procedimiento de creacion. */
export function requireCreatedId(
  output: SPOutput,
  procedureName: string,
): number {
  if (output.Id === null || output.Id === undefined) {
    throw new Error(`SP ${procedureName} no devolvio Id`);
  }
  return output.Id;
}
