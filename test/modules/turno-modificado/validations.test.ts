import { describe, it, expect } from '@jest/globals';
import { CrearTurnoModificadoSchema } from '@src/modules/turno-modificado/validations/crear-turno-modificado.validation.js';
import { ActualizarTurnoModificadoSchema } from '@src/modules/turno-modificado/validations/actualizar-turno-modificado.validation.js';
import { TurnoModificadoFilterSchema } from '@src/modules/turno-modificado/validations/turno-modificado-filter.validation.js';

const validCreate = {
  usuarioId: 25,
  fecha: '2026-08-19',
  horaInicio: '08:00',
  horaFin: '16:00:00',
};

describe('TurnoModificado validations', () => {
  it('acepta una creación válida con motivo opcional', () => {
    expect(CrearTurnoModificadoSchema.safeParse(validCreate).success).toBe(
      true,
    );
  });

  it('rechaza fecha y hora con formato inválido', () => {
    expect(
      CrearTurnoModificadoSchema.safeParse({
        ...validCreate,
        fecha: '19-08-2026',
        horaInicio: '8:00',
      }).success,
    ).toBe(false);
  });

  it('rechaza campos extra y campos obligatorios faltantes', () => {
    expect(
      CrearTurnoModificadoSchema.safeParse({
        usuarioId: 25,
        fecha: '2026-08-19',
        horaInicio: '08:00',
        extra: true,
      }).success,
    ).toBe(false);
  });

  it('acepta actualización parcial y rechaza body vacío', () => {
    expect(
      ActualizarTurnoModificadoSchema.safeParse({ horaInicio: '09:00' })
        .success,
    ).toBe(true);
    expect(ActualizarTurnoModificadoSchema.safeParse({}).success).toBe(false);
  });

  it('rechaza fechaDesde posterior a fechaHasta', () => {
    expect(
      TurnoModificadoFilterSchema.safeParse({
        fechaDesde: '2026-08-20',
        fechaHasta: '2026-08-19',
      }).success,
    ).toBe(false);
  });
});
