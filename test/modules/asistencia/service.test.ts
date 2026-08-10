import { beforeEach, describe, expect, it, jest } from '@jest/globals';

jest.mock('@src/modules/asistencia/repository.js', () => ({
  __esModule: true,
  default: {
    procesarMarcaciones: jest.fn(),
    reprocesarAsistencias: jest.fn(),
  },
}));

jest.mock('@src/common/auth.service.js', () => ({
  authService: {
    getUser: jest.fn().mockReturnValue({ id: 99, username: 'testuser' }),
  },
}));

import AsistenciaRepo from '@src/modules/asistencia/repository.js';
import { AsistenciaService } from '@src/modules/asistencia/service.js';

const repo = AsistenciaRepo as jest.Mocked<typeof AsistenciaRepo>;

describe('AsistenciaService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('procesa marcaciones usando el usuario autenticado', async () => {
    const result = {
      procesadas: 1,
      creadas: 1,
      actualizadas: 0,
      ignoradas: 0,
      errores: [],
      detalle: [],
    };
    repo.procesarMarcaciones.mockResolvedValue(result);

    await expect(AsistenciaService.procesarMarcaciones({})).resolves.toEqual(
      result,
    );
    expect(repo.procesarMarcaciones).toHaveBeenCalledWith({}, 99);
  });

  it('reprocesa asistencias usando el usuario autenticado', async () => {
    const result = {
      procesadas: 0,
      creadas: 0,
      actualizadas: 0,
      ignoradas: 0,
      errores: [],
      detalle: [],
    };
    repo.reprocesarAsistencias.mockResolvedValue(result);

    await expect(
      AsistenciaService.reprocesarAsistencias({ fecha: '2026-08-07' }),
    ).resolves.toEqual(result);
    expect(repo.reprocesarAsistencias).toHaveBeenCalledWith(
      { fecha: '2026-08-07' },
      99,
    );
  });
});
