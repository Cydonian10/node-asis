import { describe, it, expect, beforeEach, jest } from '@jest/globals';

jest.mock('@src/modules/turno-modificado/repository.js', () => ({
  __esModule: true,
  default: {
    getAll: jest.fn(),
    getById: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  },
}));

jest.mock('@src/common/auth.service.js', () => ({
  authService: {
    getUser: jest.fn().mockReturnValue({ id: 99, username: 'testuser' }),
  },
}));

import { TurnoModificadoService } from '@src/modules/turno-modificado/service.js';
import TurnoModificadoRepo from '@src/modules/turno-modificado/repository.js';

const mockedRepo = TurnoModificadoRepo as jest.Mocked<
  typeof TurnoModificadoRepo
>;

const data = {
  usuarioId: 25,
  fecha: '2026-08-19',
  horaInicio: '08:00',
  horaFin: '16:00',
  motivo: 'Cambio autorizado',
};

const modified = {
  turnoModificadoId: 1,
  turnoId: 10,
  usuarioId: 25,
  fecha: '2026-08-19',
  horaInicio: '08:00:00',
  horaFin: '16:00:00',
  motivo: 'Cambio autorizado',
};

describe('TurnoModificadoService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('lista usando el turno de la URL y los filtros', async () => {
    const filters = { fechaDesde: '2026-08-01', usuarioId: 25 };
    mockedRepo.getAll.mockResolvedValue([modified]);

    await expect(TurnoModificadoService.getAll(10, filters)).resolves.toEqual([
      modified,
    ]);
    expect(mockedRepo.getAll).toHaveBeenCalledWith(10, filters);
  });

  it('crea usando el usuario autenticado para auditoría', async () => {
    const result = { State: 1, Message: 'Creado', Id: 1, CodeError: 0 };
    mockedRepo.create.mockResolvedValue(result);

    await expect(TurnoModificadoService.create(10, data)).resolves.toEqual(
      result,
    );
    expect(mockedRepo.create).toHaveBeenCalledWith(10, data, 99);
  });

  it('mantiene el turno y el id de modificación al actualizar', async () => {
    const update = { horaInicio: '09:00' };
    const result = { State: 1, Message: 'Actualizado', CodeError: 0 };
    mockedRepo.update.mockResolvedValue(result);

    await expect(TurnoModificadoService.update(10, 1, update)).resolves.toEqual(
      result,
    );
    expect(mockedRepo.update).toHaveBeenCalledWith(10, 1, update, 99);
  });

  it('propaga el error del procedimiento para duplicados o asistencias', async () => {
    const result = {
      State: -1,
      Message: 'Ya existe una modificación activa',
      CodeError: -1,
    };
    mockedRepo.create.mockResolvedValue({ ...result, Id: null });
    mockedRepo.remove.mockResolvedValue({
      State: -1,
      Message: 'El turno tiene asistencias',
      CodeError: -1,
    });

    await expect(TurnoModificadoService.create(10, data)).resolves.toEqual({
      ...result,
      Id: null,
    });
    await expect(TurnoModificadoService.remove(10, 1)).resolves.toEqual({
      State: -1,
      Message: 'El turno tiene asistencias',
      CodeError: -1,
    });
  });
});
