import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import type { Request, Response } from 'express';

jest.mock('@src/modules/marca-biometrico/service.js', () => ({
  MarcaBiometricoService: {
    getAll: jest.fn(),
    getById: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    remove: jest.fn(),
  },
}));

import Controller from '@src/modules/marca-biometrico/controller.js';
import { MarcaBiometricoService } from '@src/modules/marca-biometrico/service.js';

const mockedService = MarcaBiometricoService as jest.Mocked<
  typeof MarcaBiometricoService
>;

function mockReq(overrides: Partial<Request> = {}): Request {
  return { params: {}, body: {}, query: {}, ...overrides } as Request;
}

function mockRes(): Response {
  return {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
  } as unknown as Response;
}

describe('MarcaBiometricoController', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('debe listar marcas', async () => {
    mockedService.getAll.mockResolvedValue([]);
    const res = mockRes();

    await Controller.getAll(mockReq(), res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith([]);
  });

  it('debe obtener una marca por id', async () => {
    const marca = {
      marcaBiometricoId: 1,
      nombre: 'ZKTeco',
      tipoDB: 'SQLServer',
      detalle: 'Acceso',
    };
    mockedService.getById.mockResolvedValue(marca);
    const req = mockReq({ params: { id: '1' } });
    const res = mockRes();

    await Controller.getById(req, res);

    expect(mockedService.getById).toHaveBeenCalledWith(1);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(marca);
  });

  it('debe responder 404 cuando la marca no existe', async () => {
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

  it('debe crear una marca', async () => {
    const result = { State: 1, Message: 'Creado', Id: 1, CodeError: 0 };
    mockedService.create.mockResolvedValue(result);
    const body = { nombre: 'ZKTeco', tipoDB: 'SQLServer', detalle: 'Acceso' };
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

  it('debe actualizar una marca', async () => {
    const result = { State: 1, Message: 'Actualizado', CodeError: 0 };
    mockedService.update.mockResolvedValue(result);
    const body = { nombre: 'ZKTeco 2', tipoDB: 'SQLServer', detalle: 'Acceso 2' };
    const req = mockReq({ params: { id: '1' }, body });
    const res = mockRes();

    await Controller.update(req, res);

    expect(mockedService.update).toHaveBeenCalledWith(1, body);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(result);
  });

  it('debe eliminar una marca', async () => {
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
