import { describe, it, expect, beforeEach, beforeAll, jest } from '@jest/globals';

const mockRepo = {
  getAll: jest.fn<(...args: unknown[]) => Promise<unknown>>(),
  create: jest.fn<(...args: unknown[]) => Promise<unknown>>(),
  update: jest.fn<(...args: unknown[]) => Promise<unknown>>(),
  remove: jest.fn<(...args: unknown[]) => Promise<unknown>>(),
};

jest.unstable_mockModule('@src/modules/usuario/repository.js', () => ({
  __esModule: true,
  default: mockRepo,
}));

let agent: ReturnType<typeof import('supertest')>;

beforeAll(async () => {
  const { default: supertest } = await import('supertest');
  const { default: app } = await import('../helpers/test-app.js');
  agent = supertest(app);
});

const BASE = '/usuarios';

describe('Usuario E2E', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe(`DELETE ${BASE}/:id`, () => {
    it('debe retornar 200 y OperationResult cuando el id es valido', async () => {
      const mockResult = { State: 1, Message: 'Eliminado', CodeError: 0 };
      mockRepo.remove.mockResolvedValue(mockResult);

      const res = await agent.delete(`${BASE}/1`);

      expect(res.status).toBe(200);
      expect(res.body).toEqual(mockResult);
    });

    it('debe retornar 400 cuando el id es 0', async () => {
      const res = await agent.delete(`${BASE}/0`);

      expect(res.status).toBe(400);
      expect(res.body.message).toBe('El id debe ser un número válido');
    });

    it('debe retornar 400 cuando el id no es numerico', async () => {
      const res = await agent.delete(`${BASE}/abc`);

      expect(res.status).toBe(400);
    });
  });
});
