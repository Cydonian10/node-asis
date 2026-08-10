import { describe, expect, it } from '@jest/globals';
import {
  classificarEntrada,
  classificarSalida,
  combinarResultado,
  nextWeekdayIso,
  prevWeekdayIso,
  targetFechas,
  weekdayOf,
} from '@src/modules/asistencia/repository.sql.js';

const estados = new Map([
  ['Asistio', 1],
  ['Tarde', 2],
  ['SalidaAnticipada', 3],
]);

const turno = (overrides: Record<string, unknown> = {}) => ({
  turnoId: 1,
  horarioDiaId: 1,
  horaInicio: '08:00:00',
  horaFin: '16:00:00',
  extendido: false,
  diaIdEntrada: 1,
  salidaDiaId: null,
  vigenciaId: null,
  fechaInicio: null,
  fechaFin: null,
  esEntradaMatch: true,
  distancia: 0,
  ...overrides,
});

describe('helpers puros de asistencia', () => {
  it('clasifica entrada a tiempo y tarde', () => {
    const target = new Date('2026-08-07T08:00:00');
    expect(
      classificarEntrada(estados, new Date('2026-08-07T08:05:00'), target, 10, 60),
    ).toBe(1);
    expect(
      classificarEntrada(estados, new Date('2026-08-07T08:30:00'), target, 10, 60),
    ).toBe(2);
    expect(
      classificarEntrada(estados, new Date('2026-08-07T10:00:00'), target, 10, 60),
    ).toBeNull();
  });

  it('clasifica salida anticipada o salida cumplida', () => {
    const target = new Date('2026-08-07T16:00:00');
    expect(
      classificarSalida(estados, new Date('2026-08-07T15:59:00'), target),
    ).toBe(3);
    expect(
      classificarSalida(estados, new Date('2026-08-07T16:00:00'), target),
    ).toBe(1);
  });

  it('combina resultados', () => {
    expect(combinarResultado('Asistio', 'Asistio')).toBe('Asistio');
    expect(combinarResultado('Asistio', 'SinMarcacionSalida')).toBe(
      'Asistio - SinMarcacionSalida',
    );
    expect(combinarResultado(null, null)).toBe('Falta');
  });

  it('calcula días de semana ISO', () => {
    expect(weekdayOf(new Date('2026-08-03T00:00:00'))).toBe(1);
    expect(weekdayOf(new Date('2026-08-09T00:00:00'))).toBe(7);
    expect(nextWeekdayIso('2026-08-07', 6)).toBe('2026-08-08');
    expect(prevWeekdayIso('2026-08-08', 5)).toBe('2026-08-07');
  });

  it('calcula las fechas de un turno extendido', () => {
    expect(
      targetFechas(
        turno({ extendido: true, salidaDiaId: 6 }),
        '2026-08-07',
      ),
    ).toEqual({ entradaIso: '2026-08-07', salidaIso: '2026-08-08' });
  });
});
