import { describe, it, expect, beforeEach, jest } from '@jest/globals';

jest.mock('@src/modules/marca-biometrico/repository.js', () => ({
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

import { MarcaBiometricoService } from '@src/modules/marca-biometrico/service.js';
import MarcaBiometricoRepo from '@src/modules/marca-biometrico/repository.js';
import type { MarcaBiometrico } from '@src/modules/marca-biometrico/dto/marca-biometrico.dto.js';

const mockedRepo = MarcaBiometricoRepo as jest.Mocked<typeof MarcaBiometricoRepo>;

describe('MarcaBiometricoService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('debe listar las marcas biometricas', async () => {
    const marcas: MarcaBiometrico[] = [
      { marcaBiometricoId: 1, nombre: 'ZKTeco', tipoDB: 'SQLServer', detalle: 'Acceso' },
    ];
    mockedRepo.getAll.mockResolvedValue(marcas);

    await expect(MarcaBiometricoService.getAll()).resolves.toEqual(marcas);
    expect(mockedRepo.getAll).toHaveBeenCalledTimes(1);
  });

  it('debe obtener una marca por id', async () => {
    const marca: MarcaBiometrico = {
      marcaBiometricoId: 1,
      nombre: 'ZKTeco',
      tipoDB: 'SQLServer',
      detalle: 'Acceso',
    };
    mockedRepo.getById.mockResolvedValue(marca);

    await expect(MarcaBiometricoService.getById(1)).resolves.toEqual(marca);
    expect(mockedRepo.getById).toHaveBeenCalledWith(1);
  });

  it('debe devolver null cuando la marca no existe', async () => {
    mockedRepo.getById.mockResolvedValue(null);

    await expect(MarcaBiometricoService.getById(999)).resolves.toBeNull();
  });

  it('debe crear una marca usando el userId del auth', async () => {
    const data = { nombre: 'ZKTeco', tipoDB: 'SQLServer', detalle: 'Acceso' };
    const result = { State: 1, Message: 'Creado', Id: 5, CodeError: 0 };
    mockedRepo.create.mockResolvedValue(result);

    await expect(MarcaBiometricoService.create(data)).resolves.toEqual(result);
    expect(mockedRepo.create).toHaveBeenCalledWith(data, 99);
  });

  it('debe actualizar una marca usando el userId del auth', async () => {
    const data = { nombre: 'ZKTeco 2', tipoDB: 'SQLServer', detalle: 'Acceso 2' };
    const result = { State: 1, Message: 'Actualizado', CodeError: 0 };
    mockedRepo.update.mockResolvedValue(result);

    await expect(MarcaBiometricoService.update(1, data)).resolves.toEqual(result);
    expect(mockedRepo.update).toHaveBeenCalledWith(1, data, 99);
  });

  it('debe eliminar una marca usando el userId del auth', async () => {
    const result = { State: 1, Message: 'Eliminado', CodeError: 0 };
    mockedRepo.remove.mockResolvedValue(result);

    await expect(MarcaBiometricoService.remove(1)).resolves.toEqual(result);
    expect(mockedRepo.remove).toHaveBeenCalledWith(1, 99);
  });
});
