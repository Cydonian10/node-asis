import { describe, expect, it } from '@jest/globals';
import { normalizeSqlTime } from '@src/modules/horario/repository.sql.js';

describe('normalizeSqlTime', () => {
  it('convierte HH:mm al formato aceptado por mssql TIME', () => {
    const result = normalizeSqlTime('08:00');
    expect(result).toBeInstanceOf(Date);
    expect(result?.getHours()).toBe(8);
    expect(result?.getMinutes()).toBe(0);
    expect(result?.getSeconds()).toBe(0);
  });

  it('conserva HH:mm:ss', () => {
    const result = normalizeSqlTime('23:59:45');
    expect(result?.getHours()).toBe(23);
    expect(result?.getMinutes()).toBe(59);
    expect(result?.getSeconds()).toBe(45);
  });

  it('acepta null y undefined para PATCH parcial', () => {
    expect(normalizeSqlTime(null)).toBeNull();
    expect(normalizeSqlTime(undefined)).toBeNull();
  });

  it('rechaza horas fuera de rango', () => {
    expect(() => normalizeSqlTime('24:00')).toThrow('La hora no es válida');
    expect(() => normalizeSqlTime('08:60')).toThrow('La hora no es válida');
  });

  it('rechaza formatos inválidos', () => {
    expect(() => normalizeSqlTime('8:00')).toThrow(
      'La hora debe tener formato HH:mm o HH:mm:ss',
    );
  });
});
