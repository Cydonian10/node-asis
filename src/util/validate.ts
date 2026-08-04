export type ValidationSchema<T> = {
  [K in keyof T]: {
    required?: boolean;
    type:
      | 'string'
      | 'number'
      | 'boolean'
      | 'date'
      | 'array'
      | 'bit'
      | 'numberOrNull';
  };
};

interface ResponseValidateSchema {
  Result: number;
  Message: string;
}

export function validateObject<T>(
  obj: Partial<T>,
  schema: ValidationSchema<T>,
): string[] {
  const errors: string[] = [];

  for (const key in schema) {
    const rules = schema[key];
    const value = obj[key];

    if (rules.required) {
      if (rules.type === 'numberOrNull') {
        if (value === undefined) {
          errors.push(`${key} es requerido`);
          continue;
        }
      } else if (value === undefined || value === null) {
        errors.push(`${key} es requerido`);
        continue;
      }
    }

    if (value !== undefined && value !== null) {
      const type = rules.type;
      switch (type) {
        case 'string':
          if (typeof value !== 'string') {
            errors.push(`${key} debe ser una cadena`);
          } else if (value.trim() === '') {
            errors.push(`${key} no debe ser una cadena vacía`);
          }
          break;
        case 'number':
          if (typeof value !== 'number')
            errors.push(`${key} debe ser un número`);
          break;
        case 'boolean':
          if (typeof value !== 'boolean')
            errors.push(`${key} debe ser un booleano`);
          break;
        case 'date':
          if (!(value instanceof Date))
            errors.push(`${key} debe ser una fecha`);
          break;
        case 'array':
          if (!Array.isArray(value)) errors.push(`${key} debe ser un arreglo`);
          break;
        case 'bit':
          if (value !== 0 && value !== 1) errors.push(`${key} debe ser 0 o 1`);
          break;
        case 'numberOrNull':
          if (value !== null && typeof value !== 'number')
            errors.push(`${key} debe ser un número o null`);
          break;
        default:
          break;
      }
    }
  }

  return errors;
}

export function messageValidateSchema(
  errors: string[],
): ResponseValidateSchema {
  return {
    Result: 1,
    Message: errors.join(' - '),
  };
}
