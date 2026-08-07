import { describe, it, expect, beforeEach, jest } from '@jest/globals';

jest.mock('@src/modules/usuario/repository.js', () => ({
  __esModule: true,
  default: {
    getAllMigrados: jest.fn(),
    getAllSync: jest.fn(),
    update: jest.fn(),
  },
}));

jest.mock('@src/common/auth.service.js', () => ({
  authService: {
    getUser: jest.fn().mockReturnValue({ id: 99, username: 'testuser' }),
    set userAuth(_u: unknown) {},
    user: { id: 99, username: 'testuser' },
  },
}));

import { UsuarioService } from '@src/modules/usuario/service.js';
import UsuarioRepo from '@src/modules/usuario/repository.js';
import type { Usuario } from '@src/modules/usuario/dto/usuario.dto.js';

const mockedRepo = UsuarioRepo as jest.Mocked<typeof UsuarioRepo>;

describe('UsuarioService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('debe listar usuarios migrados con sus filtros', async () => {
    const usuarios: Usuario[] = [];
    mockedRepo.getAllMigrados.mockResolvedValue(usuarios);

    const result = await UsuarioService.getAllMigrados(true, 'CO', 'Juan', 5);

    expect(mockedRepo.getAllMigrados).toHaveBeenCalledWith(
      true,
      'CO',
      'Juan',
      5,
    );
    expect(result).toEqual(usuarios);
  });

  it('debe listar los usuarios sincronizados', async () => {
    mockedRepo.getAllSync.mockResolvedValue([]);

    await expect(UsuarioService.getAllSync()).resolves.toEqual([]);
    expect(mockedRepo.getAllSync).toHaveBeenCalledTimes(1);
  });

  it('debe actualizar un usuario usando el userId del auth', async () => {
    const data = { esSupervisor: true, areaId: 5 };
    const result = { State: 1, Message: 'Success', CodeError: 0 };
    mockedRepo.update.mockResolvedValue(result);

    await expect(UsuarioService.update(1, data)).resolves.toEqual(result);
    expect(mockedRepo.update).toHaveBeenCalledWith(1, data, 99);
  });
});
