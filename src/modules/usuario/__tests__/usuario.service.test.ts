import { describe, it, expect, beforeEach, jest } from '@jest/globals';

jest.mock('../repository.js', () => ({
  __esModule: true,
  default: {
    getAll: jest.fn(),
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

import { UsuarioService } from '../service.js';
import UsuarioRepo from '../repository.js';

const mockedRepo = UsuarioRepo as jest.Mocked<typeof UsuarioRepo>;

describe('UsuarioService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getAll', () => {
    it('debe retornar lista de usuarios del repositorio', async () => {
      const mockUsuarios = [
        {
          id: 1,
          usuarioId: 100,
          usuario: 'jperez',
          nombre: 'Juan',
          apellido: 'Pérez',
          dni: '12345678',
          rolId: 2,
          rol: 'Docente',
          unidadId: 3,
          unidad: 'Facultad de Ingeniería',
        },
      ];
      mockedRepo.getAll.mockResolvedValue(mockUsuarios);

      const result = await UsuarioService.getAll(2, 3, 'Juan');

      expect(mockedRepo.getAll).toHaveBeenCalledWith(2, 3, 'Juan');
      expect(result).toEqual(mockUsuarios);
    });

    it('debe llamar al repositorio sin filtros cuando no se pasan parametros', async () => {
      mockedRepo.getAll.mockResolvedValue([]);

      const result = await UsuarioService.getAll();

      expect(mockedRepo.getAll).toHaveBeenCalledWith(
        undefined,
        undefined,
        undefined,
      );
      expect(result).toEqual([]);
    });
  });

  describe('create', () => {
    it('debe crear un usuario usando el userId del auth', async () => {
      const data = { usuarioId: 100, rolId: 2 };
      const mockResult = {
        Id: 1,
        State: 1,
        Message: 'Success',
        CodeError: 0,
      };
      mockedRepo.create.mockResolvedValue(mockResult);

      const result = await UsuarioService.create(data);

      expect(mockedRepo.create).toHaveBeenCalledWith(data, 99);
      expect(result).toEqual(mockResult);
    });
  });

  describe('update', () => {
    it('debe actualizar un usuario con id y data', async () => {
      const data = { rolId: 4 };
      const mockResult = { State: 1, Message: 'Success', CodeError: 0 };
      mockedRepo.update.mockResolvedValue(mockResult);

      const result = await UsuarioService.update(1, data);

      expect(mockedRepo.update).toHaveBeenCalledWith(1, data, 99);
      expect(result).toEqual(mockResult);
    });
  });

  describe('remove', () => {
    it('debe eliminar un usuario pasando el id y userId', async () => {
      const mockResult = { State: 1, Message: 'Success', CodeError: 0 };
      mockedRepo.remove.mockResolvedValue(mockResult);

      const result = await UsuarioService.remove(5);

      expect(mockedRepo.remove).toHaveBeenCalledWith(5, 99);
      expect(result).toEqual(mockResult);
    });
  });
});
