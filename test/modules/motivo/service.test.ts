import { describe, it, expect, beforeEach, jest } from '@jest/globals';

jest.mock('@src/modules/motivo/repository.js', () => ({
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
    set userAuth(_u: unknown) {},
    user: { id: 99, username: 'testuser' },
  },
}));

import { MotivoService } from '@src/modules/motivo/service.js';
import MotivoRepo from '@src/modules/motivo/repository.js';
import type { Motivo } from '@src/modules/motivo/dto/motivo.dto.js';

const mockedRepo = MotivoRepo as jest.Mocked<typeof MotivoRepo>;

describe('MotivoService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('debe listar los motivos activos', async () => {
    const motivos: Motivo[] = [
      {
        motivoId: 1,
        nombre: 'Vacaciones',
        descripcion: null,
        documentoRequerido: false,
      },
    ];
    mockedRepo.getAll.mockResolvedValue(motivos);

    await expect(MotivoService.getAll()).resolves.toEqual(motivos);
    expect(mockedRepo.getAll).toHaveBeenCalledTimes(1);
  });

  it('debe obtener un motivo por id', async () => {
    const motivo: Motivo = {
      motivoId: 1,
      nombre: 'Vacaciones',
      descripcion: null,
      documentoRequerido: false,
    };
    mockedRepo.getById.mockResolvedValue(motivo);

    await expect(MotivoService.getById(1)).resolves.toEqual(motivo);
    expect(mockedRepo.getById).toHaveBeenCalledWith(1);
  });

  it('debe crear usando el userId autenticado', async () => {
    const data = { nombre: 'Vacaciones', documentoRequerido: false };
    const result = { State: 1, Message: 'Creado', Id: 1, CodeError: 0 };
    mockedRepo.create.mockResolvedValue(result);

    await expect(MotivoService.create(data)).resolves.toEqual(result);
    expect(mockedRepo.create).toHaveBeenCalledWith(data, 99);
  });

  it('debe actualizar parcialmente usando el userId autenticado', async () => {
    const data = { documentoRequerido: true };
    const result = { State: 1, Message: 'Actualizado', CodeError: 0 };
    mockedRepo.update.mockResolvedValue(result);

    await expect(MotivoService.update(1, data)).resolves.toEqual(result);
    expect(mockedRepo.update).toHaveBeenCalledWith(1, data, 99);
  });

  it('debe eliminar logicamente usando el userId autenticado', async () => {
    const result = { State: 1, Message: 'Eliminado', CodeError: 0 };
    mockedRepo.remove.mockResolvedValue(result);

    await expect(MotivoService.remove(1)).resolves.toEqual(result);
    expect(mockedRepo.remove).toHaveBeenCalledWith(1, 99);
  });
});
