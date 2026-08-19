import { describe, it, expect } from '@jest/globals';
import { CrearControlSchema } from '@src/modules/control/validations/crear-control.validation.js';
import { ActualizarControlSchema } from '@src/modules/control/validations/actualizar-control.validation.js';
import { AsignarControlAreaSchema } from '@src/modules/control/validations/asignar-control-area.validation.js';
import { AsignarControlUnidadSchema } from '@src/modules/control/validations/asignar-control-unidad.validation.js';
import { AsignarControlUsuarioSchema } from '@src/modules/control/validations/asignar-control-usuario.validation.js';
import { DesasignarControlAreaSchema } from '@src/modules/control/validations/desasignar-control-area.validation.js';
import { DesasignarControlUnidadSchema } from '@src/modules/control/validations/desasignar-control-unidad.validation.js';
import { DesasignarControlUsuarioSchema } from '@src/modules/control/validations/desasignar-control-usuario.validation.js';

describe('Control validations', () => {
  describe('CrearControlSchema', () => {
    it('acepta valores validos', () => {
      const parsed = CrearControlSchema.safeParse({
        tolerancia: 5,
        limiteTardanza: 15,
        limiteFalta: 3,
      });
      expect(parsed.success).toBe(true);
    });

    it('rechaza un campo faltante', () => {
      const parsed = CrearControlSchema.safeParse({
        tolerancia: 5,
        limiteTardanza: 15,
      });
      expect(parsed.success).toBe(false);
    });

    it('rechaza valores negativos', () => {
      const parsed = CrearControlSchema.safeParse({
        tolerancia: -1,
        limiteTardanza: 15,
        limiteFalta: 3,
      });
      expect(parsed.success).toBe(false);
    });

    it('rechaza valores decimales', () => {
      const parsed = CrearControlSchema.safeParse({
        tolerancia: 1.5,
        limiteTardanza: 15,
        limiteFalta: 3,
      });
      expect(parsed.success).toBe(false);
    });

    it('rechaza campos no permitidos', () => {
      const parsed = CrearControlSchema.safeParse({
        tolerancia: 5,
        limiteTardanza: 15,
        limiteFalta: 3,
        extra: true,
      });
      expect(parsed.success).toBe(false);
    });
  });

  describe('ActualizarControlSchema', () => {
    it('acepta actualizacion parcial con un campo', () => {
      const parsed = ActualizarControlSchema.safeParse({ tolerancia: 10 });
      expect(parsed.success).toBe(true);
    });

    it('acepta todos los campos opcionales juntos', () => {
      const parsed = ActualizarControlSchema.safeParse({
        tolerancia: 5,
        limiteTardanza: 15,
        limiteFalta: 3,
      });
      expect(parsed.success).toBe(true);
    });

    it('rechaza un body vacio', () => {
      const parsed = ActualizarControlSchema.safeParse({});
      expect(parsed.success).toBe(false);
    });

    it('rechaza valores negativos', () => {
      const parsed = ActualizarControlSchema.safeParse({ limiteFalta: -1 });
      expect(parsed.success).toBe(false);
    });
  });

  describe('Asignacion y desasignacion', () => {
    it('acepta ids validos', () => {
      expect(AsignarControlAreaSchema.safeParse({ areaId: 1 }).success).toBe(
        true,
      );
      expect(
        AsignarControlUnidadSchema.safeParse({ unidadId: 1 }).success,
      ).toBe(true);
      expect(
        AsignarControlUsuarioSchema.safeParse({ usuarioId: 1 }).success,
      ).toBe(true);
      expect(DesasignarControlAreaSchema.safeParse({ areaId: 1 }).success).toBe(
        true,
      );
      expect(
        DesasignarControlUnidadSchema.safeParse({ unidadId: 1 }).success,
      ).toBe(true);
      expect(
        DesasignarControlUsuarioSchema.safeParse({ usuarioId: 1 }).success,
      ).toBe(true);
    });

    it('rechaza ids no positivos', () => {
      expect(AsignarControlAreaSchema.safeParse({ areaId: 0 }).success).toBe(
        false,
      );
      expect(
        AsignarControlUnidadSchema.safeParse({ unidadId: -1 }).success,
      ).toBe(false);
      expect(AsignarControlUsuarioSchema.safeParse({}).success).toBe(false);
    });

    it('rechaza campos no permitidos', () => {
      const parsed = AsignarControlAreaSchema.safeParse({
        areaId: 1,
        extra: true,
      });
      expect(parsed.success).toBe(false);
    });
  });
});
