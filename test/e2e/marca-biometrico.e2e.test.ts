import { describe, it, expect, beforeEach, beforeAll, jest } from '@jest/globals';

const mockRepo = {
  getAll: jest.fn<(...args: unknown[]) => Promise<unknown>>(),
  getById: jest.fn<(...args: unknown[]) => Promise<unknown>>(),
  create: jest.fn<(...args: unknown[]) => Promise<unknown>>(),
  update: jest.fn<(...args: unknown[]) => Promise<unknown>>(),
  remove: jest.fn<(...args: unknown[]) => Promise<unknown>>(),
};

jest.unstable_mockModule('@src/modules/marca-biometrico/repository.js', () => ({
  __esModule: true,
  default: mockRepo,
}));

let agent: ReturnType<typeof import('supertest')>;

beforeAll(async () => {
  const { default: supertest } = await import('supertest');
  const { default: app } = await import('../helpers/marca-biometrico-test-app.js');
  agent = supertest(app);
});

const BASE = '/marca-biometrico';

describe('MarcaBiometrico E2E', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe(`GET ${BASE}`, () => {
    it('debe retornar 200 con la lista de marcas', async () => {
      const marcas = [
        { marcaBiometricoId: 1, nombre: 'ZKTeco', tipoDB: 'SQLServer', detalle: 'Acceso' },
      ];
      mockRepo.getAll.mockResolvedValue(marcas);

      const res = await agent.get(BASE);

      expect(res.status).toBe(200);
      expect(res.body).toEqual(marcas);
    });
  });

  describe(`GET ${BASE}/:id`, () => {
    it('debe retornar 200 con la marca encontrada', async () => {
      const marca = { marcaBiometricoId: 1, nombre: 'ZKTeco', tipoDB: 'SQLServer', detalle: 'Acceso' };
      mockRepo.getById.mockResolvedValue(marca);

      const res = await agent.get(`${BASE}/1`);

      expect(res.status).toBe(200);
      expect(res.body).toEqual(marca);
    });

    it('debe retornar 404 cuando no existe', async () => {
      mockRepo.getById.mockResolvedValue(null);

      const res = await agent.get(`${BASE}/999`);

      expect(res.status).toBe(404);
    });

    it('debe retornar 400 cuando el id es 0', async () => {
      const res = await agent.get(`${BASE}/0`);

      expect(res.status).toBe(400);
      expect(res.body.message).toBe('El id debe ser un número válido');
    });
  });

  describe(`POST ${BASE}`, () => {
    it('debe retornar 201 con OperationResult cuando el body es valido', async () => {
      const mockResult = { State: 1, Message: 'Creado', Id: 1, CodeError: 0 };
      mockRepo.create.mockResolvedValue(mockResult);

      const res = await agent
        .post(BASE)
        .send({ nombre: 'ZKTeco', tipoDB: 'SQLServer', detalle: 'Acceso' });

      expect(res.status).toBe(201);
      expect(res.body).toEqual(mockResult);
    });

    it('debe retornar 400 cuando el body está vacío', async () => {
      const res = await agent.post(BASE).send({});

      expect(res.status).toBe(400);
    });
  });

  describe(`PUT ${BASE}/:id`, () => {
    it('debe retornar 200 y OperationResult cuando el body es valido', async () => {
      const mockResult = { State: 1, Message: 'Actualizado', CodeError: 0 };
      mockRepo.update.mockResolvedValue(mockResult);

      const res = await agent
        .put(`${BASE}/1`)
        .send({ nombre: 'ZKTeco 2', tipoDB: 'SQLServer', detalle: 'Acceso 2' });

      expect(res.status).toBe(200);
      expect(res.body).toEqual(mockResult);
    });

    it('debe retornar 400 cuando el body está vacío', async () => {
      const res = await agent.put(`${BASE}/1`).send({});

      expect(res.status).toBe(400);
    });
  });

  describe(`DELETE ${BASE}/:id`, () => {
    it('debe retornar 200 y OperationResult', async () => {
      const mockResult = { State: 1, Message: 'Eliminado', CodeError: 0 };
      mockRepo.remove.mockResolvedValue(mockResult);

      const res = await agent.delete(`${BASE}/1`);

      expect(res.status).toBe(200);
      expect(res.body).toEqual(mockResult);
    });

    it('debe retornar 400 cuando el id es invalido', async () => {
      const res = await agent.delete(`${BASE}/abc`);

      expect(res.status).toBe(400);
    });
  });
});
