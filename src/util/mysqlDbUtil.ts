/**
 * Función para construir la consulta CALL.
 * @param procedure - El nombre del procedimiento almacenado.
 * @param inputCount - La cantidad de parámetros de entrada,
 * se generan los placeholders.
 * @param includeOutput - Indica si se deben agregar parámetros de salida.
 * @param isInsert - Indica si es una operación de inserción
 * (solo se usa si includeOutput es true).
 * @returns La consulta CALL construida.
 */
export function buildCallQuery(
  procedure: string,
  inputCount: number = 0,
  includeOutput: boolean = false,
  isInsert: boolean = false,
): string {
  // Genera una cadena de placeholders, separados por coma
  const inputPlaceholders =
    inputCount > 0 ? Array(inputCount).fill('?').join(', ') : '';

  let outputPlaceholders = '';
  if (includeOutput) {
    outputPlaceholders = isInsert
      ? ', @Id, @State, @Message, @CodeError'
      : ', @State, @Message, @CodeError';
  }

  return `CALL ${procedure}(${inputPlaceholders}${outputPlaceholders})`;
}

// Constantes para recuperar los resultados de salida
export const SELECT_OUTPUT_INSERT =
  'SELECT @Id as Id, @State as State, @Message as Message, ' +
  '@CodeError as CodeError';

export const SELECT_OUTPUT_UPDATE_DELETE =
  'SELECT @State as State, @Message as Message, ' + '@CodeError as CodeError';
