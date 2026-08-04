import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import type { Request, Response } from 'express';

jest.mock('../service.js', () => ({
  UsuarioService: {
    getAll: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  },
}));

import Controller from '../controller.js';
import { UsuarioService } from '../service.js';

const mockedService = UsuarioService as jest.Mocked<typeof UsuarioService>;

function mockReq(overrides: Partial<Request> = {}): Request {
  return { params: {}, body: {}, query: {}, ...overrides } as Request;
}

function mockRes(): Response {
  const res = {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
  } as unknown as Response;
  return res;
}

describe('UsuarioController', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('remove', () => {
    it('debe retornar 200 con el resultado cuando el id es valido', async () => {
      const mockResult = { State: 1, Message: 'Success', CodeError: 0 };
      mockedService.remove.mockResolvedValue(mockResult);

      const req = mockReq({ params: { id: '5' } });
      const res = mockRes();

      await Controller.remove(req, res);

      expect(mockedService.remove).toHaveBeenCalledWith(5);
      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith(mockResult);
    });

    it('debe retornar 400 cuando el id no es un numero valido', async () => {
      const req = mockReq({ params: { id: '0' } });
      const res = mockRes();

      await Controller.remove(req, res);

      expect(mockedService.remove).not.toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        message: 'El id debe ser un número válido',
      });
    });

    it('debe retornar 400 cuando el id es NaN', async () => {
      const req = mockReq({ params: { id: 'abc' } });
      const res = mockRes();

      await Controller.remove(req, res);

      expect(res.status).toHaveBeenCalledWith(400);
    });
  });
});
