import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';

export function handleOperationResult(
  output: OperationResult,
): OperationResult {
  return {
    State: output.State,
    Message: output.Message ? String(output.Message) : 'No se encontró mensaje',
    CodeError:
      output.CodeError !== null && output.CodeError !== undefined
        ? +output.CodeError
        : 0,
  };
}

export function getFirstRecordOrNull<T>(recordset: T[]): T | null {
  return recordset[0] || null;
}

export function throwError(operation: string, error: string): never {
  throw new Error(`Handle: ${operation} || Error: ${error}`);
}

export const ErrorUtil = {
  add: (error: string) => throwError('Error al agregar', error),
  update: (error: string) => throwError('Error al actualizar', error),
  delete: (error: string) => throwError('Error al eliminar', error),
  select: (error: string) => throwError('Error al obtener resultados', error),
};

export function handleOperationResultCreate(
  output: OperationResultCreate,
): OperationResultCreate {
  if (!output) {
    throwError('Error al agregar', 'No se obtuvo resultado');
  }
  return {
    Id: output.Id !== null && output.Id !== undefined ? +output.Id : null,
    State: +output.State,
    Message: output.Message ? String(output.Message) : 'No se encontró mensaje',
    CodeError:
      output.CodeError !== null && output.CodeError !== undefined
        ? +output.CodeError
        : 0,
  };
}
