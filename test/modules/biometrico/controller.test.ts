import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import type { Request, Response } from 'express';

jest.mock('@src/modules/biometrico/service.js', () => ({
  BiometricoService: {
    getAll: jest.fn(),
    getById: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  },
}));

import Controller from '@src/modules/biometrico/controller.js';
import { BiometricoService } from '@src/modules/biometrico/service.js';

const mockedService = BiometricoService as jest.Mocked<typeof BiometricoService>;

function mockReq(overrides: Partial<Request> = {}): Request {
  return { params: {}, body: {}, query: {}, ...overrides } as Request;
}

function mockRes(): Response {
  return {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
  } as unknown as Response;
}

describe('BiometricoController', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('debe listar biometricos', async () => {
    mockedService.getAll.mockResolvedValue([]);
    const res = mockRes();

    await Controller.getAll(mockReq(), res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith([]);
  });

  it('debe obtener un biometrico por id', async () => {
    const biometrico = {
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
    mockedService.getById.mockResolvedValue(biometrico);
    const req = mockReq({ params: { id: '1' } });
    const res = mockRes();

    await Controller.getById(req, res);

    expect(mockedService.getById).toHaveBeenCalledWith(1);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(biometrico);
  });

  it('debe responder 404 cuando el biometrico no existe', async () => {
    mockedService.getById.mockResolvedValue(null);
    const req = mockReq({ params: { id: '999' } });
    const res = mockRes();

    await Controller.getById(req, res);

    expect(res.status).toHaveBeenCalledWith(404);
  });

  it('debe responder 400 con id invalido', async () => {
    const req = mockReq({ params: { id: 'abc' } });
    const res = mockRes();

    await Controller.getById(req, res);

    expect(mockedService.getById).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('debe crear un biometrico', async () => {
    const result = { State: 1, Message: 'Creado', Id: 1, CodeError: 0 };
    mockedService.create.mockResolvedValue(result);
    const body = {
      marcaBiometricoId: 1,
      nombre: 'Acceso principal',
      ip: '192.168.1.100',
      serie: 'ZK123',
      ubicacion: 'Entrada',
      tarjeta: true,
      huella: true,
      rostro: false,
    };
    const req = mockReq({ body });
    const res = mockRes();

    await Controller.create(req, res);

    expect(mockedService.create).toHaveBeenCalledWith(body);
    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(result);
  });

  it('debe rechazar un body invalido al crear', async () => {
    const req = mockReq({ body: { nombre: '' } });
    const res = mockRes();

    await Controller.create(req, res);

    expect(mockedService.create).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('debe actualizar un biometrico', async () => {
    const result = { State: 1, Message: 'Actualizado', CodeError: 0 };
    mockedService.update.mockResolvedValue(result);
    const body = {
      marcaBiometricoId: 1,
      nombre: 'Acceso principal',
      ip: '192.168.1.101',
      serie: 'ZK123',
      ubicacion: 'Entrada 2',
      tarjeta: true,
      huella: true,
      rostro: true,
    };
    const req = mockReq({ params: { id: '1' }, body });
    const res = mockRes();

    await Controller.update(req, res);

    expect(mockedService.update).toHaveBeenCalledWith(1, body);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(result);
  });

  it('debe eliminar un biometrico', async () => {
    const result = { State: 1, Message: 'Eliminado', CodeError: 0 };
    mockedService.remove.mockResolvedValue(result);
    const req = mockReq({ params: { id: '1' } });
    const res = mockRes();

    await Controller.remove(req, res);

    expect(mockedService.remove).toHaveBeenCalledWith(1);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(result);
  });
});
