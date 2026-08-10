import { beforeEach, describe, expect, it, jest } from '@jest/globals';
import type { Request, Response } from 'express';

jest.mock('@src/modules/asistencia/service.js', () => ({
  AsistenciaService: {
    procesarMarcaciones: jest.fn(),
    reprocesarAsistencias: jest.fn(),
  },
}));

import Controller from '@src/modules/asistencia/controller.js';
import { AsistenciaService } from '@src/modules/asistencia/service.js';

const service = AsistenciaService as jest.Mocked<typeof AsistenciaService>;

function mockReq(body: unknown): Request {
  return { body, params: {}, query: {} } as Request;
}

function mockRes(): Response {
  return {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
  } as unknown as Response;
}

describe('AsistenciaController', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('procesa un body válido', async () => {
    const result = {
      procesadas: 0,
      creadas: 0,
      actualizadas: 0,
      ignoradas: 0,
      errores: [],
      detalle: [],
    };
    service.procesarMarcaciones.mockResolvedValue(result);
    const res = mockRes();

    await Controller.procesarMarcaciones(
      mockReq({ usuarioId: 2001, fecha: '2026-08-07' }),
      res,
    );

    expect(service.procesarMarcaciones).toHaveBeenCalledWith({
      usuarioId: 2001,
      fecha: '2026-08-07',
    });
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(result);
  });

  it('rechaza filtros inválidos', async () => {
    const res = mockRes();

    await Controller.procesarMarcaciones(
      mockReq({ usuarioId: '2001', fecha: 'bad' }),
      res,
    );

    expect(service.procesarMarcaciones).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
  });

  it('delega el reprocesamiento', async () => {
    const result = {
      procesadas: 0,
      creadas: 0,
      actualizadas: 0,
      ignoradas: 0,
      errores: [],
      detalle: [],
    };
    service.reprocesarAsistencias.mockResolvedValue(result);
    const res = mockRes();

    await Controller.reprocesarAsistencias(mockReq({}), res);

    expect(service.reprocesarAsistencias).toHaveBeenCalledWith({});
    expect(res.status).toHaveBeenCalledWith(200);
  });
});
