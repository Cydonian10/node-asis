import { describe, it, expect, beforeEach, jest } from '@jest/globals';

jest.mock('@src/modules/control/repository.js', () => ({
  __esModule: true,
  default: {
    getAll: jest.fn(),
    getById: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
    assignArea: jest.fn(),
    assignUnidad: jest.fn(),
    assignUsuario: jest.fn(),
    unassignArea: jest.fn(),
    unassignUnidad: jest.fn(),
    unassignUsuario: jest.fn(),
  },
}));

jest.mock('@src/common/auth.service.js', () => ({
  authService: {
    getUser: jest.fn().mockReturnValue({ id: 99, username: 'testuser' }),
    set userAuth(_u: unknown) {},
    user: { id: 99, username: 'testuser' },
  },
}));

import { ControlService } from '@src/modules/control/service.js';
import ControlRepo from '@src/modules/control/repository.js';
import type { Control } from '@src/modules/control/dto/control.dto.js';

const mockedRepo = ControlRepo as jest.Mocked<typeof ControlRepo>;

const control: Control = {
  controlId: 1,
  tolerancia: 5,
  limiteTardanza: 15,
  limiteFalta: 3,
  areas: [],
  unidades: [],
  usuarios: [],
};

describe('ControlService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('debe listar los controles', async () => {
    mockedRepo.getAll.mockResolvedValue([control]);

    await expect(ControlService.getAll()).resolves.toEqual([control]);
    expect(mockedRepo.getAll).toHaveBeenCalledTimes(1);
  });

  it('debe obtener un control por id', async () => {
    mockedRepo.getById.mockResolvedValue(control);

    await expect(ControlService.getById(1)).resolves.toEqual(control);
    expect(mockedRepo.getById).toHaveBeenCalledWith(1);
  });

  it('debe devolver null cuando el control no existe', async () => {
    mockedRepo.getById.mockResolvedValue(null);

    await expect(ControlService.getById(999)).resolves.toBeNull();
  });

  it('debe crear un control usando el userId del auth', async () => {
    const data = { tolerancia: 5, limiteTardanza: 15, limiteFalta: 3 };
    const result = { State: 1, Message: 'Creado', Id: 1, CodeError: 0 };
    mockedRepo.create.mockResolvedValue(result);

    await expect(ControlService.create(data)).resolves.toEqual(result);
    expect(mockedRepo.create).toHaveBeenCalledWith(data, 99);
  });

  it('debe actualizar parcialmente un control usando el userId del auth', async () => {
    const data = { tolerancia: 10 };
    const result = { State: 1, Message: 'Actualizado', CodeError: 0 };
    mockedRepo.update.mockResolvedValue(result);

    await expect(ControlService.update(1, data)).resolves.toEqual(result);
    expect(mockedRepo.update).toHaveBeenCalledWith(1, data, 99);
  });

  it('debe eliminar un control usando el userId del auth', async () => {
    const result = { State: 1, Message: 'Eliminado', CodeError: 0 };
    mockedRepo.remove.mockResolvedValue(result);

    await expect(ControlService.remove(1)).resolves.toEqual(result);
    expect(mockedRepo.remove).toHaveBeenCalledWith(1, 99);
  });

  it('debe asignar un control a un area y devolver el control completo', async () => {
    const created = { State: 1, Message: 'Asignado', Id: 10, CodeError: 0 };
    mockedRepo.assignArea.mockResolvedValue(created);
    mockedRepo.getById.mockResolvedValue(control);

    await expect(ControlService.assignArea(1, 2)).resolves.toEqual({
      ok: true,
      control,
    });
    expect(mockedRepo.assignArea).toHaveBeenCalledWith(1, 2, 99);
    expect(mockedRepo.getById).toHaveBeenCalledWith(1);
  });

  it('debe devolver el error si la asignacion de area falla', async () => {
    const failed = {
      State: -1,
      Message: 'El area ya tiene un control asignado',
      CodeError: -1,
      Id: null,
    };
    mockedRepo.assignArea.mockResolvedValue(failed);

    await expect(ControlService.assignArea(1, 2)).resolves.toEqual({
      ok: false,
      result: failed,
    });
    expect(mockedRepo.getById).not.toHaveBeenCalled();
  });

  it('debe asignar un control a una unidad y devolver el control completo', async () => {
    const created = { State: 1, Message: 'Asignado', Id: 11, CodeError: 0 };
    mockedRepo.assignUnidad.mockResolvedValue(created);
    mockedRepo.getById.mockResolvedValue(control);

    await expect(ControlService.assignUnidad(1, 3)).resolves.toEqual({
      ok: true,
      control,
    });
    expect(mockedRepo.assignUnidad).toHaveBeenCalledWith(1, 3, 99);
  });

  it('debe asignar un control a un usuario y devolver el control completo', async () => {
    const created = { State: 1, Message: 'Asignado', Id: 12, CodeError: 0 };
    mockedRepo.assignUsuario.mockResolvedValue(created);
    mockedRepo.getById.mockResolvedValue(control);

    await expect(ControlService.assignUsuario(1, 4)).resolves.toEqual({
      ok: true,
      control,
    });
    expect(mockedRepo.assignUsuario).toHaveBeenCalledWith(1, 4, 99);
  });

  it('debe desasignar el control de un area y devolver el control completo', async () => {
    const result = { State: 1, Message: 'Desasignado', CodeError: 0 };
    mockedRepo.unassignArea.mockResolvedValue(result);
    mockedRepo.getById.mockResolvedValue(control);

    await expect(ControlService.unassignArea(1, 2)).resolves.toEqual({
      ok: true,
      control,
    });
    expect(mockedRepo.unassignArea).toHaveBeenCalledWith(1, 2, 99);
  });

  it('debe desasignar el control de una unidad y devolver el control completo', async () => {
    const result = { State: 1, Message: 'Desasignado', CodeError: 0 };
    mockedRepo.unassignUnidad.mockResolvedValue(result);
    mockedRepo.getById.mockResolvedValue(control);

    await expect(ControlService.unassignUnidad(1, 3)).resolves.toEqual({
      ok: true,
      control,
    });
    expect(mockedRepo.unassignUnidad).toHaveBeenCalledWith(1, 3, 99);
  });

  it('debe desasignar el control de un usuario y devolver el control completo', async () => {
    const result = { State: 1, Message: 'Desasignado', CodeError: 0 };
    mockedRepo.unassignUsuario.mockResolvedValue(result);
    mockedRepo.getById.mockResolvedValue(control);

    await expect(ControlService.unassignUsuario(1, 4)).resolves.toEqual({
      ok: true,
      control,
    });
    expect(mockedRepo.unassignUsuario).toHaveBeenCalledWith(1, 4, 99);
  });

  it('debe devolver el error si la desasignacion de usuario falla', async () => {
    const failed = {
      State: -1,
      Message: 'La asignacion del control al usuario no existe',
      CodeError: -1,
    };
    mockedRepo.unassignUsuario.mockResolvedValue(failed);

    await expect(ControlService.unassignUsuario(1, 4)).resolves.toEqual({
      ok: false,
      result: failed,
    });
    expect(mockedRepo.getById).not.toHaveBeenCalled();
  });
});
