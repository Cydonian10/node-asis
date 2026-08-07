import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import type { Request, Response } from 'express';

jest.mock('@src/modules/usuario/service.js', () => ({
  UsuarioService: {
    getAllMigrados: jest.fn(),
    getAllSync: jest.fn(),
    update: jest.fn(),
  },
}));

import Controller from '@src/modules/usuario/controller.js';
import { UsuarioService } from '@src/modules/usuario/service.js';

const mockedService = UsuarioService as jest.Mocked<typeof UsuarioService>;

function mockReq(overrides: Partial<Request> = {}): Request {
  return { params: {}, body: {}, query: {}, ...overrides } as Request;
}

function mockRes(): Response {
  return {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
  } as unknown as Response;
}

describe('UsuarioController', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('debe actualizar area y supervisor', async () => {
    const result = { State: 1, Message: 'Success', CodeError: 0 };
    mockedService.update.mockResolvedValue(result);

    const req = mockReq({
      params: { id: '5' },
      body: { areaId: 3, esSupervisor: true },
    });
    const res = mockRes();

    await Controller.update(req, res);

    expect(mockedService.update).toHaveBeenCalledWith(5, {
      areaId: 3,
      esSupervisor: true,
    });
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(result);
  });

  it('debe rechazar body vacío', async () => {
    const req = mockReq({ params: { id: '5' }, body: {} });
    const res = mockRes();

    await Controller.update(req, res);

    expect(mockedService.update).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
  });
});
