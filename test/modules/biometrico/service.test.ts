import { describe, it, expect, beforeEach, jest } from '@jest/globals';

jest.mock('@src/modules/biometrico/repository.js', () => ({
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

import { BiometricoService } from '@src/modules/biometrico/service.js';
import BiometricoRepo from '@src/modules/biometrico/repository.js';
import type { Biometrico } from '@src/modules/biometrico/dto/biometrico.dto.js';

const mockedRepo = BiometricoRepo as jest.Mocked<typeof BiometricoRepo>;

describe('BiometricoService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('debe listar los biometricos', async () => {
    const biometricos: Biometrico[] = [
      {
        biometricoId: 1,
        marcaBiometricoId: 1,
        marcaNombre: 'ZKTeco',
        nombre: 'Acceso principal',
        ip: '192.168.1.100',
        serie: 'ZK123',
        ubicacion: 'Entrada',
        tarjeta: true,
        huella: true,
        rostro: false,
      },
    ];
    mockedRepo.getAll.mockResolvedValue(biometricos);

    await expect(BiometricoService.getAll()).resolves.toEqual(biometricos);
    expect(mockedRepo.getAll).toHaveBeenCalledTimes(1);
  });

  it('debe obtener un biometrico por id', async () => {
    const biometrico: Biometrico = {
      biometricoId: 1,
      marcaBiometricoId: 1,
      marcaNombre: 'ZKTeco',
      nombre: 'Acceso principal',
      ip: '192.168.1.100',
      serie: 'ZK123',
      ubicacion: 'Entrada',
      tarjeta: true,
      huella: true,
      rostro: false,
    };
    mockedRepo.getById.mockResolvedValue(biometrico);

    await expect(BiometricoService.getById(1)).resolves.toEqual(biometrico);
    expect(mockedRepo.getById).toHaveBeenCalledWith(1);
  });

  it('debe devolver null cuando el biometrico no existe', async () => {
    mockedRepo.getById.mockResolvedValue(null);

    await expect(BiometricoService.getById(999)).resolves.toBeNull();
  });

  it('debe crear un biometrico usando el userId del auth', async () => {
    const data = {
      marcaBiometricoId: 1,
      nombre: 'Acceso principal',
      ip: '192.168.1.100',
      serie: 'ZK123',
      ubicacion: 'Entrada',
      tarjeta: true,
      huella: true,
      rostro: false,
    };
    const result = { State: 1, Message: 'Creado', Id: 5, CodeError: 0 };
    mockedRepo.create.mockResolvedValue(result);

    await expect(BiometricoService.create(data)).resolves.toEqual(result);
    expect(mockedRepo.create).toHaveBeenCalledWith(data, 99);
  });

  it('debe actualizar un biometrico usando el userId del auth', async () => {
    const data = {
      marcaBiometricoId: 1,
      nombre: 'Acceso principal',
      ip: '192.168.1.101',
      serie: 'ZK123',
      ubicacion: 'Entrada 2',
      tarjeta: true,
      huella: true,
      rostro: true,
    };
    const result = { State: 1, Message: 'Actualizado', CodeError: 0 };
    mockedRepo.update.mockResolvedValue(result);

    await expect(BiometricoService.update(1, data)).resolves.toEqual(result);
    expect(mockedRepo.update).toHaveBeenCalledWith(1, data, 99);
  });

  it('debe eliminar un biometrico usando el userId del auth', async () => {
    const result = { State: 1, Message: 'Eliminado', CodeError: 0 };
    mockedRepo.remove.mockResolvedValue(result);

    await expect(BiometricoService.remove(1)).resolves.toEqual(result);
    expect(mockedRepo.remove).toHaveBeenCalledWith(1, 99);
  });
});
