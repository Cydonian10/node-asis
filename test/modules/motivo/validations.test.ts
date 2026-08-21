import { describe, it, expect } from '@jest/globals';
import { CrearMotivoSchema } from '@src/modules/motivo/validations/crear-motivo.validation.js';
import { ActualizarMotivoSchema } from '@src/modules/motivo/validations/actualizar-motivo.validation.js';

describe('Motivo validations', () => {
  it('acepta un motivo valido y aplica documentoRequerido false por defecto', () => {
    const parsed = CrearMotivoSchema.safeParse({
      nombre: '  Vacaciones  ',
      descripcion: 'Solicitud de vacaciones',
    });

    expect(parsed.success).toBe(true);
    if (parsed.success) {
      expect(parsed.data).toEqual({
        nombre: 'Vacaciones',
        descripcion: 'Solicitud de vacaciones',
        documentoRequerido: false,
      });
    }
  });

  it('rechaza nombre vacio o mayor a 100 caracteres', () => {
    expect(CrearMotivoSchema.safeParse({ nombre: '   ' }).success).toBe(false);
    expect(
      CrearMotivoSchema.safeParse({ nombre: 'a'.repeat(101) }).success,
    ).toBe(false);
  });

  it('rechaza descripcion mayor a 255 caracteres', () => {
    expect(
      CrearMotivoSchema.safeParse({
        nombre: 'Motivo',
        descripcion: 'a'.repeat(256),
      }).success,
    ).toBe(false);
  });

  it('rechaza campos no permitidos', () => {
    expect(
      CrearMotivoSchema.safeParse({ nombre: 'Motivo', extra: true }).success,
    ).toBe(false);
  });

  it('acepta actualizacion parcial y permite limpiar descripcion', () => {
    expect(ActualizarMotivoSchema.safeParse({ nombre: 'Nuevo nombre' }).success).toBe(
      true,
    );
    expect(ActualizarMotivoSchema.safeParse({ descripcion: null }).success).toBe(
      true,
    );
  });

  it('rechaza actualizacion vacia', () => {
    expect(ActualizarMotivoSchema.safeParse({}).success).toBe(false);
  });
});
