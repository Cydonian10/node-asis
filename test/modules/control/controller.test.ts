import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import type { Request, Response } from 'express';

jest.mock('@src/modules/control/service.js', () => ({
  ControlService: {
    getAll: jest.fn(),
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

import Controller from '@src/modules/control/controller.js';
import { ControlService } from '@src/modules/control/service.js';

const mockedService = ControlService as jest.Mocked<typeof ControlService>;

function mockReq(overrides: Partial<Request> = {}): Request {
  return { params: {}, body: {}, query: {}, ...overrides } as Request;
}

function mockRes(): Response {
  return {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
  } as unknown as Response;
}

const control = {
  controlId: 1,
  tolerancia: 5,
  limiteTardanza: 15,
  limiteFalta: 3,
  areas: [],
  unidades: [],
  usuarios: [],
};

describe('ControlController', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('debe listar controles', async () => {
    mockedService.getAll.mockResolvedValue([]);
    const res = mockRes();

    await Controller.getAll(mockReq(), res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith([]);
  });

  it('debe crear un control', async () => {
    const result = { State: 1, Message: 'Creado', Id: 1, CodeError: 0 };
    mockedService.create.mockResolvedValue(result);
    const body = { tolerancia: 5, limiteTardanza: 15, limiteFalta: 3 };
    const req = mockReq({ body });
    const res = mockRes();

    await Controller.create(req, res);

    expect(mockedService.create).toHaveBeenCalledWith(body);
    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(result);
  });

  it('debe rechazar un body invalido al crear', async () => {
    const req = mockReq({ body: { tolerancia: -1 } });
    const res = mockRes();

    await Controller.create(req, res);

    expect(mockedService.create).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('debe actualizar un control', async () => {
    const result = { State: 1, Message: 'Actualizado', CodeError: 0 };
    mockedService.update.mockResolvedValue(result);
    const body = { tolerancia: 10 };
    const req = mockReq({ params: { id: '1' }, body });
    const res = mockRes();

    await Controller.update(req, res);

    expect(mockedService.update).toHaveBeenCalledWith(1, body);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(result);
  });

  it('debe rechazar una actualizacion con body vacio', async () => {
    const req = mockReq({ params: { id: '1' }, body: {} });
    const res = mockRes();

    await Controller.update(req, res);

    expect(mockedService.update).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('debe eliminar un control', async () => {
    const result = { State: 1, Message: 'Eliminado', CodeError: 0 };
    mockedService.remove.mockResolvedValue(result);
    const req = mockReq({ params: { id: '1' } });
    const res = mockRes();

    await Controller.remove(req, res);

    expect(mockedService.remove).toHaveBeenCalledWith(1);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(result);
  });

  it('debe asignar un control a un area', async () => {
    mockedService.assignArea.mockResolvedValue({ ok: true, control });
    const req = mockReq({ params: { id: '1' }, body: { areaId: 2 } });
    const res = mockRes();

    await Controller.assignArea(req, res);

    expect(mockedService.assignArea).toHaveBeenCalledWith(1, 2);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(control);
  });

  it('debe responder 400 cuando el area ya tiene un control', async () => {
    const failed = {
      State: -1,
      Message: 'El area ya tiene un control asignado',
      CodeError: -1,
    };
    mockedService.assignArea.mockResolvedValue({ ok: false, result: failed });
    const req = mockReq({ params: { id: '1' }, body: { areaId: 2 } });
    const res = mockRes();

    await Controller.assignArea(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(failed);
  });

  it('debe asignar un control a una unidad', async () => {
    mockedService.assignUnidad.mockResolvedValue({ ok: true, control });
    const req = mockReq({ params: { id: '1' }, body: { unidadId: 3 } });
    const res = mockRes();

    await Controller.assignUnidad(req, res);

    expect(mockedService.assignUnidad).toHaveBeenCalledWith(1, 3);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(control);
  });

  it('debe asignar un control a un usuario', async () => {
    mockedService.assignUsuario.mockResolvedValue({ ok: true, control });
    const req = mockReq({ params: { id: '1' }, body: { usuarioId: 4 } });
    const res = mockRes();

    await Controller.assignUsuario(req, res);

    expect(mockedService.assignUsuario).toHaveBeenCalledWith(1, 4);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(control);
  });

  it('debe desasignar el control de un area', async () => {
    mockedService.unassignArea.mockResolvedValue({ ok: true, control });
    const req = mockReq({ params: { id: '1' }, body: { areaId: 2 } });
    const res = mockRes();

    await Controller.unassignArea(req, res);

    expect(mockedService.unassignArea).toHaveBeenCalledWith(1, 2);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(control);
  });

  it('debe desasignar el control de una unidad', async () => {
    mockedService.unassignUnidad.mockResolvedValue({ ok: true, control });
    const req = mockReq({ params: { id: '1' }, body: { unidadId: 3 } });
    const res = mockRes();

    await Controller.unassignUnidad(req, res);

    expect(mockedService.unassignUnidad).toHaveBeenCalledWith(1, 3);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(control);
  });

  it('debe desasignar el control de un usuario', async () => {
    mockedService.unassignUsuario.mockResolvedValue({ ok: true, control });
    const req = mockReq({ params: { id: '1' }, body: { usuarioId: 4 } });
    const res = mockRes();

    await Controller.unassignUsuario(req, res);

    expect(mockedService.unassignUsuario).toHaveBeenCalledWith(1, 4);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(control);
  });

  it('debe responder 400 con id invalido en asignacion', async () => {
    const req = mockReq({ params: { id: 'abc' }, body: { areaId: 2 } });
    const res = mockRes();

    await Controller.assignArea(req, res);

    expect(mockedService.assignArea).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('debe rechazar un body invalido al desasignar', async () => {
    const req = mockReq({ params: { id: '1' }, body: { areaId: 0 } });
    const res = mockRes();

    await Controller.unassignArea(req, res);

    expect(mockedService.unassignArea).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
  });
});
